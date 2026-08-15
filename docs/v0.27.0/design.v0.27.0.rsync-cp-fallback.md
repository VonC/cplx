# Design v0.27.0 -- Install without the host rsync

Reference issue: [issue.v0.27.0.rsync-cp-fallback.md](issue.v0.27.0.rsync-cp-fallback.md)

Umbrella: [draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md)

---

## Context for v0.27.0 rsync-cp-fallback

`install_pkg.sh` relocates the tools archive onto a bare account. It calls
`rsync` at two sites and dies with exit 5 where the binary is absent,
which is the case on the Debian 12 CI agent image. The consuming project
has been papering over this with a stand-in shim on the bootstrap
`PATH`, a workaround that only happens to work because CI installs into
an empty prefix.

The requirement settled nine clarifications across four review rounds.
This design turns them into a coherent shape for the script, and its
whole difficulty is asymmetry: the engine that must change is the one
nobody has problems with, and the engine being introduced is the one
that will only ever run where nobody is watching. Every choice below is
made so that the rsync path stays exactly as it is while the fallback
becomes provable.

## Scope for v0.27.0 rsync-cp-fallback

The v0.27.0 outcomes are:

1. `install_pkg.sh` completes a relocation on a host with no `rsync`,
   with no external shim and no change to its published exit contract.
2. The RHEL path keeps the same rsync operation, output, semantics, exit
   codes and resulting tree, gaining only new surrounding diagnostics.
3. The two engines are provably equivalent, on a defined manifest, with
   the evidence retained.

Everything else is either supporting design context for those outcomes
or explicitly deferred.

### In scope for v0.27.0 rsync-cp-fallback

- One engine decision per run, covering both call sites.
- A mirror fallback reproducing `--delete` for the whole-tree case, with
  an explicit destination boundary guarding its destructive step.
- A root-file deploy fallback.
- A validation override that forces the fallback where rsync exists.
- Operation-named failure messages behind the unchanged exit codes 5
  and 7.
- The audited host-tool contract, with its inventory method, recorded in
  the wiki reference, and the script header corrected.

### Deferred from v0.27.0 rsync-cp-fallback to later work

- Race-resistant deletion. The mirror destination boundary is a check
  immediately followed by a recursive delete, so concurrent replacement
  of `<prefix>/<target>` between the two is out of scope.
- Race-resistant root-file deployment, on the same terms and without
  qualification. The preflight observes the destination type and then
  copies, so a concurrent replacement between the two can restore any
  hazard. `--remove-destination` does not narrow that: removing an
  existing destination and opening the new one are separate path
  operations, so a swap between them reaches the same outcomes. M4
  measured destination shapes established before each copy ran and never
  swapped one mid-operation, so it says nothing about concurrency at
  all. The whole concurrent-replacement problem is outside this
  guarantee, and closing it would need a deployment technique this
  design does not adopt.
- A shipped tree comparator. The equivalence is proved once, by a recipe
  in the validation plan; a comparator usable on the CI agent would
  itself have to live inside the host-tool contract this issue defines.
- Widening the host-tool audit beyond `install_pkg.sh` and its `echos`
  helper. `pkg.sh` and the other relocation helpers keep no audited
  contract.
- Removal of the consuming project's rsync shim, which belongs to that
  repository and depends on which installer its pipeline runs.
- Adding rsync and procps to the Jenkins agent image, a CICD-team track
  that stays useful and stays non-blocking.

---

## Confirmed Technical Facts for v0.27.0 rsync-cp-fallback

These facts were confirmed by inspecting the current codebase before
writing this design.

**Two rsync call sites, two fatal codes**: line 454 mirrors the staging
tree with `rsync -av --delete "$SOURCE_PATH/" "$DEST_PATH/"` and fatals
5; line 469 deploys each archive root file with
`rsync -av "$root_file" "$INSTALL_PREFIX/"` and fatals 7. Both codes are
published in `wiki/reference/relocation-tools.md`, named after the
engine rather than the operation, and `wiki/reference/exit-codes.md`
points at that table.

**The mirror feeds a symlink rewrite**: `fix_home_symlink_targets
"$DEST_PATH"` runs at line 457, immediately after the mirror, and
rewrites link targets without following them. It can only act on links
the copy preserved as links, which makes symlink fidelity a
correctness property of the copy rather than a nicety.

**Link structure is load-bearing in the archive**: the loader resolves
the SONAME `libgcc_s.so.1` through a link onto
`libgcc_s-11-20240719.so.1`, and a directory on the toolchain rpath can
itself be a link, as `root/lib64` is onto `usr/lib64`. Dereferencing
links would multiply one physical library into several that the later
patchelf pass would then patch separately; dropping them would break the
SONAME lookup and send the loader to the host copy.

**Diagnostic helpers already exist**: lines 17 to 31 source `echos` from
the script's own directory or one level up, and define `task`, `info`,
`ok`, `warning`, `error` and `fatal` inline when it is absent. Any new
diagnostic uses them and works standalone next to an archive.

**The host-tool contract is Bash and GNU, not POSIX**: the interpreter
is `#!/bin/bash` with `shopt`, arrays and `[[`; the script relies on
`find -printf` (393), `grep -rlIZ --exclude-dir` and `xargs -0 -r` into
`sed -i` (184, 185). `gzip` is mandatory although it appears nowhere as
a command: line 437 runs `tar -xzf`, and GNU tar's `-z` filters through
the external `gzip` binary. `cp` is not called by the current script at
all; the fallback introduces it, and `cp -a` is a GNU and BSD extension.

**The archive carries no producer metadata**: `pkg.sh` line 130 creates
the tarball with `tar --sort=name ... -cf - | gzip -n` and the installer
extracts with `tar -xzf`, neither passing `--acls`, `--xattrs` or
`--selinux`. Extraction can still create target-local ACLs and SELinux
labels, which `cp -a` attempts to preserve and `rsync -a` does not.

**The copy form decides the transfer root's metadata** (measured
2026-08-09, recorded in the umbrella's detail for this item): `cp -a`
keeps a link a link on the RHEL server and on the agent alike, so
symlink fidelity rests on a verified capability rather than on a manual
page. More sharply, given the same populated destination,
`cp -a src/. dst/` leaves the destination root carrying the source mode
and the source mtime, which is exactly what `rsync -av --delete src/
dst/` does, while copying entry by entry leaves the destination its own
mode and a fresh mtime. Both targets agree, on coreutils 8.32 with rsync
and on 9.1 without. The divergence is therefore a property of the copy
form, not of the engine.

**Failure already leaves staging behind**: the mirror runs after
extraction, and the staging directory is only removed at line 502 on
success. Line 424 removes an old staging directory before the next
extraction, so a rerun after a failure is already the recovery path.

---

## Current Behavior for v0.27.0 rsync-cp-fallback

```txt
resolve prefix -> find newest archive -> extract to staging
  -> rsync -av --delete staging/<target>/ -> <prefix>/<target>/   (fatal 5)
  -> fix_home_symlink_targets
  -> for each staging root file: rsync -av file -> <prefix>/       (fatal 7)
  -> fix_text_paths, clear_pycache, fix_elf_paths, bin entries
```

Both rsync calls are unconditional. Nothing detects the engine, nothing
names it, and the only trace is a task line that says a sync is
happening without saying what performs it.

## Target Behavior for v0.27.0 rsync-cp-fallback

```txt
resolve prefix -> decide engine ONCE -> announce engine
  -> find newest archive -> extract to staging
  -> mirror(staging/<target>/ -> <prefix>/<target>/)               (fatal 5)
       rsync engine:    rsync -av --delete            (unchanged)
       cp engine:       check destination boundary    (fatal 5, pre-delete)
                        create or empty destination
                        cp -a src/. dst/              (form is load-bearing)
  -> fix_home_symlink_targets                          (unchanged)
  -> for each staging root file: deploy(file -> <prefix>/)         (fatal 7)
       rsync engine:    rsync -av                     (unchanged)
       cp engine:       non-following type check      (fatal 7, pre-copy)
                        accept absent or real regular file only
                        cp -a
  -> unchanged tail
```

The engine decision is taken once, before any work, and both transfer
sites consult that one verdict. The tail of the sequence is untouched:
whichever engine ran, the tree handed to `fix_home_symlink_targets` and
the passes after it is the same tree.

---

## Engine selection for v0.27.0 rsync-cp-fallback

### One decision, taken early and announced

The verdict is computed once and reused, rather than probed at each call
site, so a run cannot mirror with one engine and deploy root files with
another. What the two sites share is that verdict and nothing else: they
stay independent paths rather than one transfer abstraction with two
operations. They differ in the property that matters most here, whether
they delete, and the mirror's destructive boundary must apply to exactly
one of them. Keeping them apart makes it structurally impossible to
apply that boundary to the wrong operation or to omit it from the right
one, and the duplication it costs is one branch on an
already-computed verdict. Announcing it before the transfer, not after, means a run that
dies mid-copy has already said which engine was copying.

The line carries three things, because each answers a question a reader
of an install log actually has: the engine, the resolved binary path
when rsync was selected, and the reason when the fallback was forced.
The resolved path is not decoration. `command -v rsync` finds the
consuming project's stand-in shim exactly as readily as a real rsync,
and that shim silently ignores `--delete`; printing what was resolved
turns an invisible degradation into a visible one.

### Absence selects the fallback, failure does not

The fallback is chosen when rsync is absent, never when a present rsync
returns non-zero. An rsync that exists and fails is a real error about
the tree, the permissions or the disk, and retrying it with another
engine would convert a diagnosable failure into a silent success with
different semantics.

### The override is a test surface, not an operating mode

Two acceptance criteria cannot be executed without running the fallback
on a host that has rsync: the redeployment that must reproduce
`--delete` over a populated prefix, and the two-engine comparison. The
override exists for those, and its shape follows from who invokes the
installer: wrapper scripts owned by another repository (the consuming
project's `deploy_pkgs.sh`, the Jenkins stages). An environment variable
reaches them without editing any of them, where a command-line flag
would have to be threaded through each caller.

The interface is fixed here rather than left to the plan, because a
variable read by another repository's scripts is a contract the moment
it exists: `CPLX_INSTALL_PKG_FORCE_CP=1`, following the repository's
`CPLX_*` convention. Only the exact value `1` forces the fallback. Any
other value behaves as unset, which fails safe, and the run stays
readable because the selected-engine trace reports what was actually
chosen rather than what was requested. Forced runs use a disposable test
prefix; the override never licenses running the non-atomic path against
a live deployment prefix.

## Mirror semantics for v0.27.0 rsync-cp-fallback

### Reproducing `--delete` for the only case this script uses

The script mirrors a whole tree onto a whole tree. For that case,
emptying the destination content and copying the source content is
equivalent to `--delete`, and it is the only equivalence this design
owes: no partial-tree, filter or exclusion behavior of rsync is in
scope, because no call site uses one.

The copy preserves symlinks as links and preserves hard links.

The copy form is a design constraint rather than an implementation
detail, because one choice carries two separate properties. Copying
`src/.` into the destination, rather than copying entries one by one,
is what makes the destination root take the source mode and mtime,
matching what rsync does to its transfer root, and it is also what
carries hidden entries without depending on the caller's globbing
options. Hidden entries matter on both sides: the archive root and the
tools tree both hold them, and a copy that skipped them would leave
stale hidden files behind on a redeployment. Choosing the other form
would cost the equivalence a carve-out and cost the mirror its hidden
entries, for nothing gained.

### The destructive step needs a boundary the copy step does not

The fallback empties the destination before copying, so a wrong
destination costs whatever was there, and that deserves its own rule
rather than an implicit one.

An earlier version of this section justified the rule by contrast,
saying the fallback was the more dangerous engine and that rsync removes
only entries it knows about. M1 disproves both halves. Under `--delete`,
rsync given a destination that is a symlink to a directory follows the
link and deletes entries in the external target, returning 0. It is not
the safer engine on that shape; it is the one that destroys data outside
the destination it was given and reports success. The rule below exists
because the fallback's delete is recursive and unbounded if pointed at
the wrong place, not because rsync is careful.

The boundary accepts two shapes and refuses everything else: an absent
destination, which it creates, or a real directory, whose content it
empties. A regular file, a special file, or a symlink of any kind fails
the mirror step before a single entry is removed. The delete acts on the
path derived from the installer's own arguments and does not traverse a
destination observed as a symlink, so a misconfigured prefix is a
diagnosable error rather than data loss somewhere else on the
filesystem.

The wrong-type cases are not one case, and M1 now says which is which
on RHEL 9.8 with rsync 3.2.5. Three real-directory shapes succeed and
mirror the source. A regular file, a symlink to a regular file and a
FIFO are refused with exit 3, and a dangling symlink fails with exit 11.
One shape is genuinely dangerous: **rsync follows a mirror destination
that is a symlink to a directory, and under `--delete` it empties the
external target while returning 0**. Nothing in the destination the
installer was given is touched, and the caller is told the mirror
succeeded.

That measurement sharpens the asymmetry rather than softening it. The
fallback refuses every present destination that is not a real directory,
including the symlink-to-directory shape on which the unchanged rsync
path can delete outside the apparent destination and report success. So
the stricter engine is the new one, and the shape where the difference
bites is the one where rsync is silently destructive.

M3 inspected two real deployment prefixes, and both `tools` entries are
real directories, not symlinks, which is the shape both engines handle
identically. That is two prefixes, corrected on 2026-08-11 from an
earlier reading of one. Every other deployment prefix remains
uninspected, so M3 narrows the risk without establishing that the
symlink shape never occurs.

The guarantee is scoped honestly to that observation. A check followed
by a recursive delete is a time-of-check-to-time-of-use sequence, and
this design does not promise race-freedom it would have to buy with a
different deletion technique.

### Non-atomicity is accepted, and its recovery is stated

A failure between the delete and the end of the copy leaves a partial
destination. This is accepted rather than engineered away: the
alternative, staging beside the tree and renaming into place, would give
the two engines different semantics and would change the staging
contract `pkg.sh` and `install_pkg.sh` share, which belongs to the
packaging items later in the collection.

The recovery already exists in the script and is now stated rather than
discovered: the staging tree survives a failure, the next run clears an
old staging directory before extracting, and rerunning the same command
from the same archive rebuilds a complete tree.

## Root-file deploy for v0.27.0 rsync-cp-fallback

### The preflight is a safety rule, and M2 is why

Two earlier versions of this design got this step wrong in opposite
directions. The first claimed the danger was silent nesting, which GNU
`cp` does not do. The second concluded, correctly for what was then
known, that a boundary here would only improve diagnostics. M2 measured
both engines over eight destination shapes and found two hazards that
belong to the fallback engine itself:

- **Copy through a symlink.** Where `prefix/<name>` is a symlink to a
  regular file, `cp -a file prefix/` follows the link, overwrites the
  external target and returns 0. The link survives, the file the
  operator was pointing at does not, and the install reports success.
  rsync on the same shape returns 0 having replaced the link and left
  its target untouched. Both succeed; their effects are opposite.
- **Hang on a FIFO.** Where the entry is a FIFO, `cp` blocks. The
  measured 124 is a probe timeout after twenty seconds, not an engine
  failure, which means an unattended install would wait forever rather
  than fail.

Both results reproduce on coreutils 8.32 and 9.1, so these are fallback
engine semantics rather than a distribution accident. The boundary is
therefore a safety rule, not a tidiness one, and the "diagnostic
quality" justification this design carried in round 2 is withdrawn.

### What the preflight accepts, and how it must observe

The fallback accepts exactly two shapes: an absent destination, and an
existing **real regular file**, which it overwrites. Every directory,
every kind of symlink, every FIFO and every other special file fails the
root-file step with exit 7 before `cp` is invoked.

The type observation must not follow symlinks. This is the load-bearing
detail: a following predicate would classify a symlink to a regular file
as an acceptable "regular file" and preserve exactly the overwrite
hazard the rule exists to remove. The design does not choose a shell
construct, but it requires a non-following observation, and it requires
the FIFO refusal to happen before any copy begins so that the installer
cannot block.

The rsync path keeps its measured behavior unchanged, including the
shapes where it replaces what the fallback refuses. That asymmetry is
deliberate and is the same trade as the mirror boundary.

### Why the check cannot be replaced by a safer copy form

M4 asked whether the preflight could be dropped in favour of a copy form
that is safer on its own. It cannot. Given a destination already
standing in an unsafe shape when the copy runs,
`--remove-destination` and a copy-then-rename both handle a symlink to a
regular file and a FIFO, but both still follow a symlink to a directory
and both still nest the payload inside a real directory, with exit 0 in
each case. Two of the four unsafe shapes survive every form measured, so
the non-following preflight stays load-bearing.

What that buys, stated exactly, because the temptation to overclaim it
is strong. If the symlink-to-regular-file or FIFO shape is present when
`cp` processes the destination, `--remove-destination` replaces it
promptly without touching an external target. That is a statement about
a destination that is already in that shape, which is what M4 measured.
It is not a statement about a destination that becomes that shape while
the installer is working: removing the existing destination and opening
the new one are separate path operations, so a swap between them reaches
the same outcomes as before. The flag is static defense in depth and
nothing more; concurrency is out of scope entirely, per the deferrals.

`--remove-destination` is preferred over copy-then-rename on that basis
and on cost. It covers the same two static shapes, and it is the only
one of the two that is contract-neutral: it adds no command to the
audited host-tool inventory and leaves nothing behind on failure. The
rename form needs `mv`, which the installer does not invoke today, so
adopting it would widen the audited contract, and it can strand a hidden
temporary file.

One caution this design records rather than resolves, because M4 proved
it matters: the target-directory spelling and the explicit-name spelling
of the same copy behave differently on a real directory, refusing with
exit 1 in the first case and nesting with exit 0 in the second. The
preflight makes both safe, which is the point of keeping it, but the
plan must not treat the two spellings as interchangeable.

## Failure and diagnostic contract for v0.27.0 rsync-cp-fallback

### Exit codes describe the operation, not the engine

Codes 5 and 7 stay, for both engines, including the destination-boundary
refusal, which is a mirror-step failure. They are a contract with
callers this repository does not own, and the reason to touch them is
not that the failure changed but that their published names said
"rsync" where they meant "mirror" and "root file deploy". The messages
name the failed step and the engine that failed it; the wiki entry is
reworded to match.

### What is invariant on the rsync path, and what is not

The invariant is scoped to the rsync operation: its invocation, its own
per-entry output, its copy semantics, its exit codes, and the tree it
produces. The install's complete output is not invariant, and cannot be:
the engine line and the operation-named error text are new by design.
Stating the invariant at the wrong altitude would make it false on the
day it is written.

The fallback prints neither per-file output nor entry counts. Counts
were considered and rejected: they cost a traversal, and a count that
matches proves nothing about whether the right bytes arrived. The
evidence that a mirror succeeded is the command status plus the
equivalence comparison below.

## Equivalence and validation model for v0.27.0 rsync-cp-fallback

### The manifest, and what it deliberately leaves out

Two trees, **each installed into a fresh prefix**, are compared entry by
entry over relative path, entry type, regular-file bytes, mode, mtime
and symlink target. Entry type is in the list so that a file replacing a
directory is caught. Ownership is the installing account, stated as
expected or normalized when two validations run under different
accounts.

Amended 2026-08-11 on measurement, retained as
`measurements.mtime-engines.rhel.txt`. This section first claimed parity
without qualification. On a fresh prefix the parity is exact, mtime
included to the nanosecond, for both engines through the forms this
design selects. Over a populated prefix it is not, and the reason is
rsync's default quick check rather than anything in the fallback: given
an already-present destination whose size and integer-second mtime match
the source, rsync decides no transfer is needed and leaves that entry
alone, where the fallback empties the destination first and always
rewrites it. Measured, the destination kept `.987654321` where the
source was `.123456789`, while the fallback produced the source value.

That divergence is the reason the comparison is defined on fresh
prefixes, and it is recorded here rather than left to the plan, because
the scope of the parity claim belongs to the design that makes it. It
changes no decision: the rsync path is unchanged, which is the point,
and what a redeployment must guarantee is stated behaviourally in the
requirement rather than as parity between engines.

Amended 2026-08-14 on acceptance measurement, retained as
`verify.acceptance.rhel.txt` with its three manifests. The parity above
is a claim about the copy **forms**, and as such it holds. The
acceptance row compares finished **installs**, which is a larger object:
the text path fix, the ELF fix and the `__pycache__` clear all rewrite
files after the copy, so those entries carry the mtime of the run rather
than of the copy. The unchanged same-engine control defines the
run-variant set: paths whose mtimes differ between two fresh rsync
installs. On the published archive that set contains 592 of 30665 paths
and is the same set whose mtimes differ between engines. Independent
inspection attributes those paths to the post-copy passes; that
attribution explains the result but does not define eligibility. The
other 30073 agree exactly on every recorded field, mtime included to the
nanosecond, across both engines.

The run-variant set is therefore compared behaviourally rather than by equality:
the same entries must exist under both engines with the same type, size,
mode, ownership, content digest and link target, and each mtime must
fall inside the wall-clock window of its own install. The set is not
declared, it is measured by the same-engine control. Exact equality
there is not achievable across two separate runs of the current
installer without adding timestamp normalization. That normalization is
rejected because it would change installed metadata solely for a one-off
parity proof rather than preserve copy-engine behaviour.

The transfer root, `<prefix>/<target>` itself, is part of that
comparison and is expected to agree, with no carve-out. That is a
consequence of the copy form above rather than an assumption: the
2026-08-09 measurement shows both engines leaving the root with the
source mode and mtime once the fallback copies `src/.`. An earlier
version of this design proposed excluding the root, on the belief that
the fallback could only ever leave it with a fresh mtime; the
measurement removed the question.

Hard-link topology is a permitted divergence, in the fallback's favour:
`cp -a` preserves hard links while `rsync -a` expands them into copies
unless given `-H`.

ACLs, extended attributes and SELinux labels are outside parity, and the
ground matters. It is not that the trees cannot differ there, they can:
extraction may create target-local metadata that `cp -a` preserves and
`rsync -a` does not. It is that `rsync -a` never promised parity for
those attributes, normal RHEL operation stays on rsync, and what this
design validates is the runtime behavior of the relocated tree. A future
archive that starts transporting metadata reopens the exclusion.

### Canaries chosen for what breaks silently

The comparison names two checks explicitly, because they are the
failures that would pass a casual look: `libgcc_s.so.1` must still be a
symlink onto `libgcc_s-11-20240719.so.1` rather than a second copy of
that file, and every directory on the toolchain rpath must keep its
nature, real directory or link. A tree that fails either would still
look complete and would still install, and would break at load time
somewhere else.

Beyond the manifest, the relocated prefix is checked for resolution: the
shipped loader lists the python ELF and the toolchain libraries with no
`not found` line the rsync-produced tree did not already have.

### Proved once, with the evidence kept

The equivalence is a property of this change rather than of the archive,
and the fallback path is not something later items keep editing, so it
is proved once, on a pair of fresh prefixes. The validation plan carries
the recipe, exact enough to reproduce the manifest, normalizing the
permitted differences and checking the canaries; its output is retained
as evidence rather than reduced to a verdict. Nothing is shipped: a
comparator useful on the CI agent would itself have to run inside the
host-tool contract this design defines.

Proving it once on fresh prefixes is now a measured choice rather than a
convenient one. A redeployment comparison between engines would fail for
the reason above, and failing it would ask the implementation to satisfy
a promise the unchanged rsync path does not make. The contract is
therefore fresh-install manifest equivalence: exact outside the
same-engine run-variant mtime set, and exact on every non-mtime field
plus own-install window containment inside that set. It sits beside the
redeployment behaviour the requirement defines per engine, and the two
are deliberately different kinds of claim.

## Documented contract for v0.27.0 rsync-cp-fallback

### The inventory travels with its method

The wiki reference gains the host-tool contract in four groups: the Bash
language and its builtins; the mandatory external programs, `gzip` and
`cp` included; the optional rsync; and the shipped patchelf, which is
resolved from the archive before `PATH` and is not a host requirement at
all.

The method is recorded beside the list, and this is the part that earns
its place. The list covers two kinds of dependency: commands in command
position, and external subprocesses that command options start. A
token-only scan finds only the first kind, which is why `gzip` was
missing from three successive versions of this inventory while careful
readers looked straight at it. `tar -xzf` is the only case of the second
kind in this script.

### The script header stops overstating

The header already promises the installer needs only the archive,
itself, and the shipped patchelf. That becomes true for the outlier this
work removes, and the header points at the recorded contract for the
rest rather than implying there is nothing else.

---

## Measurement evidence behind this design for v0.27.0 rsync-cp-fallback

Four questions rested on tool behavior rather than on judgement, and
they were measured in two campaigns on both supported targets. The raw
outputs are retained beside this design, indexed by
[measurements.index.md](measurements.index.md).

- M1, M2 and M3, on 2026-08-09: the destination-shape runs for RHEL 9.8
  and Debian 12, the Debian mirror-root probe and the Debian
  installer-contract probe. Each row below can be checked against its
  `--- M1 case:` or `--- M2 engine` block in those files.
- M4, on 2026-08-10: the copy-form runs, retained as their own outputs
  for RHEL 9.8 and Debian 12. Its rows point at those files rather than
  at the destination-shape ones.

M4 differs from the other three in what it can support, and the
distinction governs how its result is used below. It established each
destination shape before invoking the copy; it never replaced a
destination while a copy was running. Its results therefore describe
static shapes only and say nothing about concurrent replacement.

The pattern is worth keeping. Of the claims this effort made about tool
behavior, every measured one has held and several argued ones have not:
the POSIX host contract, the transfer-root metadata, the silent-nesting
premise, and now the belief that a root-file boundary was cosmetic.

### M1, mirror destination by shape (RHEL 9.8, rsync 3.2.5)

| Destination shape | Exit | Outcome |
| --- | --- | --- |
| absent | 0 | created, mirrors the source |
| empty real directory | 0 | mirrors the source |
| populated real directory | 0 | mirrors the source, stale entries deleted |
| regular file | 3 | refused, `cannot stat destination`, untouched |
| symlink to empty directory | 0 | followed, writes into the external target |
| symlink to populated directory | 0 | followed, **deletes the external content**, returns success |
| symlink to regular file | 3 | refused, target unchanged |
| dangling symlink | 11 | refused, `mkdir failed: File exists` |
| FIFO | 3 | refused, `cannot stat destination` |

The Debian target has no rsync, so M1 exists only for RHEL. The
consequence for this design is in the mirror-semantics area: the one
shape where the two engines diverge dangerously is the symlink to a
populated directory, and there the unchanged engine is the destructive
one.

### M2, root-file destination by shape (both engines)

| Prefix entry shape | rsync | `cp` |
| --- | --- | --- |
| absent | 0, file created | 0, file created |
| regular file | 0, overwritten in place | 0, overwritten in place |
| empty directory | 0, directory replaced by the file | 1, refused, directory intact |
| populated directory | 23, refused, intact | 1, refused, intact |
| symlink to directory | 0, link replaced, target untouched | 1, refused, link and target intact |
| symlink to regular file | 0, link replaced, target untouched | 0, **follows the link and overwrites the external target** |
| dangling symlink | 0, link replaced by the file | 1, refused, link intact |
| FIFO | 0, FIFO replaced by the file | 124, **blocked**, killed after 20s, FIFO intact |

The engines agree on two shapes of eight. The `cp` column reproduced
identically on coreutils 8.32 and 9.1, so the two hazards are engine
semantics rather than a distribution accident. This is what makes the
root-file preflight a safety rule.

### M4, three root-file copy forms over the same eight shapes

Taken to test whether a copy form handles the M2 hazards on its own, so
the root-file guarantee would depend less on the preflight. Every shape
was established before the copy was invoked, so these results are about
destinations already standing in that shape, not about destinations that
change during the operation. The forms:
F1 `cp -a src prefix/name`, F2 `cp -a --remove-destination src
prefix/name`, F3 `cp -a src prefix/.name.tmp` then `mv -f`. Both targets
agree in all twenty-four cells; only timings differ.

| Destination shape | F1 | F2 | F3 |
| --- | --- | --- | --- |
| symlink to a regular file | rewrites the external target | link replaced, **external target byte-identical, mtime untouched** | same as F2 |
| FIFO | **blocks**, killed at 20010 ms | replaced in 15 ms | replaced in 25 ms |
| symlink to a directory | follows, writes inside the external directory, exit 0 | **same**, `--remove-destination` does not unlink a link to a directory | **same**, `mv -f` renames into the directory the link points at |
| real directory, empty or populated | payload nests inside it, exit 0 | **same** | **same**, and under the hidden `.name.tmp` name |

So neither candidate removes the need for the preflight. Each handles
two of the four statically unsafe shapes, which is real and worth
having, but two shapes defeat every form: a symlink to a directory, and
a real directory. The non-following preflight is therefore required, and
that is now a measured conclusion rather than an assumption.

Of the two candidates, F2 is preferred. It covers the same shapes as F3
and is the only one that is contract-neutral: it adds no command to the
audited host-tool inventory and leaves nothing behind when it fails. F3
needs `mv`, which the installer does not invoke today, so adopting it
would widen the audited contract, and on the shape where its rename step
fails it leaves `prefix/.name.tmp` behind for the installer to clean up.

**The spelling of the copy matters as much as its options.** M2 measured
`cp -a file prefix/`, the target-directory form, which refuses a real
directory with exit 1. M4 measured `cp -a src prefix/name`, the
explicit-name form, which nests inside it with exit 0. That is not a
contradiction between the two measurements; it is two different
commands. The explicit-name spelling is the less safe of the two, and
any concrete command this design leads to has to be read with that in
mind.

### M3, deployment prefix shape

| Prefix | `<prefix>/tools` | Mode |
| --- | --- | --- |
| first inspected RHEL prefix | real directory | `drwxrwxr-x+`, extended ACL |
| second inspected RHEL prefix | real directory | `drwxr-xr-x.`, SELinux context |

Two prefixes were inspected, and both `tools` entries are the shape both
engines handle identically. Every other deployment prefix remains
uninspected, so this narrows the risk of the Q03 asymmetry without
eliminating it.

Corrected on 2026-08-11. This subsection, the mirror-semantics area and
Q03 all said one prefix. That came from the measurement index, which
itself said one while the raw output beside it recorded two, and nobody
opened the raw file until a sensitive-term substitution pass did. No
decision changes: both prefixes hold the safe shape, and two prefixes
are still not a survey. The evidence is simply one prefix stronger than
this design claimed, and the index is corrected too.

The trailing marks are worth recording for a different reason: the first
directory carries an extended ACL and the second an SELinux context, so
two distinct pieces of the excluded metadata class are present in
production rather than one. That does not reopen the
requirement's deliberate exclusion of ACLs from cross-engine parity,
which rests on `rsync -a` never having promised them. It does mean the
excluded metadata is present in production rather than hypothetical, so
this design must not be read as claiming it is absent.

### Evidence still owed, in validation rather than here

Two raw outputs were not durably retained: the RHEL installer-contract
probe and the RHEL transfer-root probe. The index records their absence,
and their results are quoted in the umbrella rather than in a retained
file, so nothing here rests on an output a reader could open. The
decisive destination-shape evidence is retained, so their absence does
not block this design. Regenerating and retaining them belongs to
validation follow-up, and is recorded here so a quoted result is not
mistaken for a retained one.

Validation owes one more thing, which follows from M4 rather than from a
missing file: it must exercise the exact copy spelling this design
selects, not only the preflight cases. M4 showed that two spellings of
the same command differ on a real directory, so a validation that
checked the preflight while the implementation used the other spelling
would pass without testing what ships.

---

## Design decisions for v0.27.0 rsync-cp-fallback

Settled across five design review rounds (2026-08-09 to 2026-08-11),
recorded in
[the review transcript](review.design-specification.v0.27.0.rsync-cp-fallback.md).
Three of these were decided by measurement after an argued answer proved
wrong; those rows say so, because the reason is part of the decision.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | The mirror and the root-file deploy stay independent paths sharing one engine verdict and nothing else | Engine selection (one decision, taken early and announced) | One transfer abstraction with two operations, rejected because it invents a shared concept over two callers where only one may ever carry the destructive boundary; expressing the root-file deploy as a degenerate mirror, rejected because a single-file copy has no delete semantics to share |
| Q02 | Withdrawn before any answer, on measurement. The mirror fallback copies `src/.` into the destination, which gives the transfer root the source mode and mtime exactly as rsync does, and carries hidden entries without depending on globbing options | Mirror semantics (copy form); Equivalence model (transfer root in the manifest, no carve-out) | Excluding the transfer root from the compared manifest, and adding a metadata alignment step to the fallback, both made unnecessary once the copy form was measured rather than assumed |
| Q03 | The mirror destination boundary guards the fallback only, refusing every present destination that is not a real directory. The rsync path keeps its measured behavior | Mirror semantics (destination boundary); Umbrella follow-up section | Guarding both engines, rejected because the settled requirement holds the rsync invocation, output, semantics and exit codes unchanged, so it would reopen the requirement; warning without failing on the rsync path, rejected as noise that still changes that path's output. M1 measured what keeping it costs: rsync follows a symlink to a directory and, under `--delete`, empties the external target returning 0. That defect is now a dated umbrella backlog entry rather than prose here |
| Q04 | The validation override is `CPLX_INSTALL_PKG_FORCE_CP=1`. Only the exact value `1` forces the fallback; anything else behaves as unset and leaves rsync selected | Engine selection (the override is a test surface); Acceptance cases | Describing the shape without fixing name and value, rejected in round 1 review because a variable read by another repository's scripts would then be agreed twice; a command-line flag, rejected because every intermediate caller would have to thread it through; tolerant value parsing, rejected because the consumers are scripts |
| Q05 | The root-file fallback accepts only an absent destination or a real regular file. Every directory, every symlink, every FIFO and every other special file fails with exit 7 before `cp` runs, and the type observation must not follow symlinks | Root-file deploy (preflight, accepted shapes, non-following observation); Acceptance cases | Leaving it undefined, rejected on M2, which measured `cp -a` following a symlink to a regular file and overwriting an external target with exit 0, and blocking on a FIFO; replacing whatever is present, rejected as a larger action than the step is entitled to take. Two earlier justifications were wrong and are recorded as such: silent nesting, which GNU `cp` does not do, and diagnostic quality, which M2 disproved |
| Q06 | The engine is decided and announced once, before archive discovery, as a selection rather than an action | Engine selection; Target behaviour flow | Announcing immediately before the mirror, rejected because a failure during archive discovery or extraction would then carry no engine information, and those steps genuinely fail on a foreign target; deciding lazily at first use, rejected because it reopens the single-verdict guarantee |
| Q07 | Concurrent replacement is wholly outside the root-file guarantee, matching the mirror rule. `cp -a --remove-destination src prefix/name` is adopted as static defense in depth, with no concurrency claim | Deferrals (race-resistant root-file deployment); Root-file deploy (why the check cannot be replaced); M4 evidence | Requiring race resistance, rejected because nothing in the audited contract provides it: `--remove-destination` unlinks then opens, two path operations with a window between them, and copy-then-rename has its own path races plus a need for `mv`, absent from the contract; keeping the plain copy form, rejected because it discards a free static improvement. M4 measured static shapes only, and an earlier reading of it as partial race resistance was corrected in round 4 review |

## Acceptance Cases for v0.27.0 rsync-cp-fallback

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| Debian 12, no rsync, no shim, empty prefix | `cp` engine announced, `<prefix>/tools` created, install completes | The defect this work removes |
| RHEL 9.8, rsync present, no override | rsync engine and resolved path announced, then the unchanged `rsync -av` operation and tree | The invariant the whole design protects |
| Populated prefix, `cp` engine, stale entry no longer in the archive | Entry gone, hidden entries included | `--delete` equivalence for the whole-tree case |
| rsync present and returning non-zero | Exit 5, no fallback attempt | Absence selects the fallback, failure does not |
| `cp` engine, `<prefix>/tools` is a regular file or a symlink | Exit 5 before any deletion, symlink target untouched | The destructive step's boundary |
| `cp` engine, `<prefix>/<name>` is a symlink to a regular file | Exit 7 before copying, link intact, external target byte-identical | M2: `cp -a` would follow the link and overwrite that target while returning 0 |
| `cp` engine, `<prefix>/<name>` is a FIFO | Exit 7 promptly, no copy started, FIFO intact | M2: `cp` blocks on a FIFO, so the refusal must precede the copy or an unattended install hangs |
| Same two shapes with rsync present | rsync's measured behavior, unchanged | The asymmetry is deliberate: the new engine is the stricter one |
| `cp` engine interrupted mid-copy | Partial destination, staging retained, rerun restores a complete tree | Non-atomicity accepted with a stated recovery |
| Two engines over the same archive | Manifest agrees, transfer root included, both roots carrying the source mode and mtime; hard-link topology may differ; `libgcc_s.so.1` still a link. On the same-engine run-variant set, every non-mtime field agrees and each mtime falls inside its own install window, per the amendment above | Equivalence under the exact-plus-behavioural comparison, the root agreeing because of the copy form |
| `CPLX_INSTALL_PKG_FORCE_CP=1` on a host with rsync | Fallback runs, engine line states it was forced | The test surface that makes two criteria executable |
| `CPLX_INSTALL_PKG_FORCE_CP` set to anything else | Treated as unset, rsync selected, trace reports rsync | Fail safe, and the trace reports what was chosen rather than what was asked |
| Target image without `gzip` | Fails at extraction, before any transfer | Why the inventory must carry option-selected subprocesses |
