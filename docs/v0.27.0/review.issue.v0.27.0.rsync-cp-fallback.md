# Specification review transcript for v0.27.0

- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor

- Recorded: 2026-08-08T22:08:30+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for issue rsync-cp-fallback round 1

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
Review round: 1

### Requestor assessment for issue rsync-cp-fallback round 1

The issue describes Q19 completely at the requirement level: the two `rsync`
call sites of `src/setups/env/bin/install_pkg.sh` (lines 454 and 469), their
published exit codes 5 and 7, the external shim the consuming project writes on
the CI bootstrap `PATH`, the confirmed rule chosen by decision D4, the gap list,
worked examples, code references, an eight-bullet acceptance list, and an
explicit out-of-scope section. Symlink fidelity is stated as load-bearing rather
than incidental, with the `libgcc_s.so.1` link and the `root/lib64` directory
link as the concrete cases.

Eight open questions are placed. No reviewer wording suggestions have been
applied yet: this is round 1 and no answer exists.

Whether questions are missing: three areas were deliberately left unasked, and
the reviewer should confirm each exclusion rather than assume it.

- The archive-shipped rsync payload and the compiled-in-cplx variant are settled
  by decision D4 in the umbrella, so reopening them here would re-litigate a
  recorded decision.
- The developer helper `src/setups/env/bin/rsync.sh` and the `.env_user` aliases
  share the name but not the purpose; they are named in the out-of-scope section.
- The rpath work that makes shipped libraries resolve inside the prefix belongs
  to item 2 of the same collection, and this issue only promises not to damage
  the link structure that work depends on.

Whether the existing options and answers are sufficient: four points deserve
particular reviewer attention.

- Q01 and Q02 interact and should be judged together. Q01 accepts a non-atomic
  mirror (empty the destination, then copy) on the argument that the fallback
  only runs where rsync is absent, that is on disposable CI containers. Q02 then
  recommends an override that makes the same fallback runnable on a RHEL target
  that has rsync. The pair is coherent only if the override is understood as a
  validation instrument; the reviewer should say whether that needs to be stated
  as a constraint, or whether Q01 should instead require a safe swap.
- Q05 rests on a fact taken from `wiki/reference/relocation-tools.md`, that
  `install_pkg.sh` both travels inside every tools archive and runs standalone
  beside one. Which of those two routes the consuming project's pipeline uses
  today is not established in the umbrella, in the child draft, or in the Jenkins
  build synthesis. The recommended answer 5C is therefore built on a capability
  rather than on an observed pipeline behavior, and the reviewer should judge
  whether the acceptance wording can stand on that.
- Q07 excludes extended attributes and SELinux contexts from the equivalence
  definition, on the argument that requiring parity would force `-X` and `-A`
  onto the rsync command that must stay byte-identical on RHEL. That argument is
  sound only if the deployed tree does not depend on context labels; the reviewer
  should challenge it if the RHEL 9.8 targets run SELinux in enforcing mode for
  this prefix.
- Q04 recommends keeping exit codes 5 and 7 for both engines. The reviewer
  should say whether a CI stage that reads only the exit status has a real need
  to distinguish the engines, which is the single argument that would move the
  answer to 4B or 4C.

Whether the acceptance list is complete: it covers the fresh-prefix install, the
redeployment delete semantics, the engine trace, RHEL invariance, tree
equivalence with its permitted divergence, loader resolution, the
present-but-failing rsync case, and the downstream shim removal. Two candidate
gaps the reviewer may want added: the behavior when the mirror destination
exists but is not a directory, and whether the staging area left behind after a
failure is part of the expected post-failure state.

### Change summary for issue rsync-cp-fallback round 1

Round 1, so there is no preceding round to compare against. The reviewed
document was produced in this cycle, in three steps:

1. Written as `docs/issue.v0.27.0.rsync-cp-fallback.md` from the umbrella
   `draft.v0.27.0.debian-agent-tools.md` (work item 4, question Q19, decision
   D4), the child draft `draft.v0.27.0.rsync-cp-fallback.md`, and the consuming
   project's `docs/jenkins_build_synthesis.md`. The type is `issue`, matching the
   umbrella backlog row and the child draft front matter, rather than the
   `feature-request` name used in the invocation.
2. Moved with its two drafts into the full-version layout `docs/v0.27.0/`. All
   relative links were re-anchored one level deeper, and the two cross-repository
   references in the consuming project's synthesis were repaired to the new path.
3. Eight open questions appended through `oqm`, covering the interrupted-mirror
   state, an override to exercise the fallback where rsync exists, the content of
   the engine trace, the exit-code contract, the date the consuming project may
   drop its shim, the reach of the POSIX-only bootstrap guarantee, the definition
   of tree equivalence, and whether a reusable comparator is a deliverable.

Three statements in the document go beyond what the two source drafts carry, and
each was checked against the repository rather than inferred:

- the exit codes and their published wording, read from `install_pkg.sh` and from
  `wiki/reference/relocation-tools.md`;
- the `fix_home_symlink_targets` call that runs on the mirrored tree immediately
  after the copy, which is the second reason symlink preservation is
  load-bearing;
- the dual delivery route of the installer, inside the archive and standalone
  beside it, which is what question Q05 turns on.

### Writer response for issue rsync-cp-fallback round 1

Writer response: No reviewer feedback exists yet: this is the first request of the exchange, so
nothing has been accepted, adapted, or disputed.

Two boundaries the writer intends to hold, stated up front so a disagreement can
be raised in the first answer rather than in a later round:

- Decisions already recorded in the umbrella are not reopened here. D4 settled
  the in-script `cp` fallback against shipping or compiling rsync, and the
  reasoning is quoted in the document. A reviewer recommendation to revisit D4
  belongs to the umbrella, not to this issue.
- Implementation shape is out of scope for a requirement review. Questions about
  which shell construct performs the copy, how the helper functions are factored,
  or where the detection line sits belong to the design and plan phases that
  follow.

Everything else is open, including the recommended answers, the acceptance list,
and the out-of-scope section.

### Reviewer focus for issue rsync-cp-fallback round 1

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-08T22:44:47+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 1

The issue is well grounded in Q19, the two actual installer call sites, the
published exit-code contract, and the symlink evidence. D4 remains authoritative
and is not reopened.

The requirement is not ready to consolidate. It describes an exhaustive
POSIX-only bootstrap contract, but the installer is Bash, uses GNU-specific
`find -printf` and `grep -Z`, selects non-POSIX `cp -a`, and invokes several
baseline commands omitted from the stated list. The supported promise is removal
of the observed host-rsync dependency on Debian 12 and RHEL 9.8, not general
POSIX portability.

One open question is missing: the fallback destination boundary. Before recursive
deletion, allow only an absent destination or a real directory; a non-directory
or symlink destination should fail with mirror-step code 5 before deletion and
must not permit mutation outside the derived destination. Staging retention does
not need another question: state directly that a failed fallback may leave a
partial destination, retains staging, and is recovered by rerunning.

### Question-by-question decisions for specification reviewer round 1

1. Q01: accept 1A with corrected scope. Any host without rsync naturally reaches
   the fallback; Q02 is not the only route. Forced RHEL validation must use a
   disposable prefix, and failure/recovery state must be explicit.
2. Q02: accept 2B as a validation-only override with an explicit affirmative
   value and a trace saying fallback was forced. Normal operation still prefers
   rsync.
3. Q03: no current option is sufficient. Log engine, resolved rsync path, and
   forced reason as applicable; retain existing rsync verbosity; require neither
   per-file cp output nor copied/removed counts. Q08, not a count, proves
   equivalence.
4. Q04: accept 4A. Preserve codes 5 and 7 and put the engine in the diagnostic.
5. Q05: accept 5C's intent but remove the deadline claim. cplx proves the
   standalone fixed installer against the existing archive; downstream removes
   its shim only after it actually adopts a fixed installer by either route.
6. Q06: no current answer is safe. Replace the POSIX premise with an audited
   Bash/GNU supported-target contract, or keep this issue narrowly responsible
   for removing rsync without claiming an exhaustive command inventory.
7. Q07: accept 7A after defining relative path, entry type, bytes, mode, mtime,
   symlink target, and normalized install-account ownership. Permit hard-link
   topology differences and explicitly exclude ACLs, xattrs, and SELinux labels
   based on the existing archive/rsync contract.
8. Q08: accept 8A. Record an exact one-off manifest recipe and its result in the
   validation plan; no shipped comparator is required.

### Requested changes for specification reviewer round 1

1. Correct the portability narrative and Q06.
2. Add the destination safety question and fail-before-delete acceptance.
3. Constrain Q02 to validation and document Q01 failure/recovery state.
4. Replace Q03's counts with the engine/path/forced-reason trace.
5. Separate Q05's local proof from downstream adoption.
6. Tighten Q07's manifest and attribute exclusions.
7. Add acceptance for hidden stale entries, disposable forced redeployment, and
   the exact Q08 evidence.

Disposition: changes-requested. Apply these substantive corrections and start
another automated review round; do not consolidate on this round.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor

- Recorded: 2026-08-08T23:00:50+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for issue rsync-cp-fallback round 2

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
Review round: 2

### Requestor assessment for issue rsync-cp-fallback round 2

Every round 1 requested change has been applied. The reviewer's central finding
was verified against the script before being acted on, rather than accepted on
authority, and it held on every checkable point.

Verification of the portability finding, since the largest edit depends on it:

- `install_pkg.sh` line 393 uses `find ... -printf '%T@ %p\n'`, a GNU findutils
  extension.
- Line 184 uses `grep -rlIZ --exclude-dir=__pycache__`, where `-Z`, `-I` and
  `--exclude-dir` are GNU extensions, piped at line 185 into `xargs -0 -r`, where
  `-r` is a GNU extension, driving `sed -i`, which POSIX does not specify.
- The interpreter is `#!/bin/bash` and the script uses `shopt -s dotglob
  nullglob`, arrays and `[[`.
- The command inventory over the whole file is about twenty distinct commands,
  not the eight the round 1 document listed: the missing ones include printf,
  echo, mkdir, rm, sort, head, cut, tr, xargs, basename, dirname, readlink,
  chmod, touch, file and `command`.
- `cp -a`, which the chosen fallback uses, is itself a GNU and BSD extension.

The archive-format argument behind the round 1 Q07 correction was also checked:
`pkg.sh` line 130 creates the tarball with `tar --sort=name "${EXCLUDE_PARAMS[@]}"
-C "$HOME" -cf - ... | gzip -n` and `install_pkg.sh` line 437 extracts it with
`tar -xzf`, neither passing `--acls`, `--xattrs` or `--selinux`. The exclusion of
those attributes from parity is therefore a statement about this archive, not an
assumption about the target's SELinux mode.

What changed in the document:

- The opening section now carries the audited command inventory, names the GNU
  and Bash dependencies with their line numbers, and states plainly that the
  earlier "all POSIX baseline" claim was wrong. It also records that the
  umbrella's D4 rationale, "leaves the installer needing only POSIX tools", is
  inaccurate in the same way, while the decision D4 recorded is unaffected.
- A fifth gap, the destination boundary, joins the gap analysis.
- The confirmed rule gained the destination boundary, the non-atomicity contract
  with its retained staging and rerun recovery, the trace content, the tightened
  per-entry equivalence manifest with ownership handling, and the ACL, xattr and
  SELinux exclusion grounded in the tar flags.
- The examples gained a hidden stale entry, a non-directory and symlinked
  destination, and an interrupted fallback.
- Acceptance is split into what cplx can close on and what is tracked
  downstream, and gained the boundary refusal, the interrupted-run recovery, the
  forced-fallback redeployment into a disposable prefix, and retention of the
  comparison output as evidence.
- Questions: Q01, Q02, Q05, Q07 and Q08 amended; Q03 gained replacement option 3D
  and answer; Q06 gained option 6D and answer, replacing the rejected 6C; Q04
  unchanged at 4A; Q09 added for the destination boundary.

Whether questions are still missing: the reviewer's own judgement that the
staging-after-failure state needs no separate question was followed, and that
contract is now stated in the confirmed rule and in acceptance instead. No new
question is proposed this round.

Points where the reviewer may want to press further:

- Q09 option 9A deliberately refuses a symlinked `<prefix>/<target>` on the
  fallback path, which rsync accepts today. That is a behavior difference between
  the two engines, chosen because a recursive delete through a symlink is
  unbounded. If any deployment symlinks that directory onto another volume, this
  is the line that would break, and the reviewer is better placed than the writer
  to say whether such a deployment exists.
- Q06 option 6D commits to recording an audited contract in the wiki. The audit
  above is the writer's, taken from one reading of one script; if the reviewer
  wants the contract to cover `pkg.sh` and the relocation helpers as well, that
  is a wider scope than this issue currently claims.
- Q07 excludes ACLs and extended attributes on the strength of today's tar flags.
  If the packaging items later in the collection add `--xattrs`, this exclusion
  becomes stale, and the requirement says so but does not own that future change.

### Change summary for issue rsync-cp-fallback round 2

Changes since round 1, mapped to the seven requested changes of the round 1
answer.

1. Portability narrative and Q06. The "all POSIX baseline" claim and the
   eight-command list are gone from the opening section, the CDC revision
   history and the gap analysis. They are replaced by an audited inventory with
   the GNU and Bash dependencies named at their line numbers, and by an explicit
   correction paragraph that also flags the same inaccuracy in the umbrella's D4
   rationale. Q06 was rewritten around the real question, what contract the
   installer promises, with rejected option 6C kept for the record and new option
   6D recommended.
2. Destination boundary. New question Q09 with option 9A recommended, absent or
   real directory only, exit 5 before any deletion otherwise, no traversal of a
   symlinked destination and no mutation outside the derived path. A fifth bullet
   was added to the gap analysis, a rule to the confirmed rule, two examples, and
   an acceptance line.
3. Q01 and Q02. Q01 no longer claims the override is the only route to the
   fallback, and now states the partial destination, the retained staging
   directory and the rerun recovery. Q02 labels the override a validation
   instrument, requires an explicit affirmative value, requires the trace to say
   the fallback was forced, and forbids presenting it as permission to run
   against a live prefix.
4. Q03. New option 3D recommended: one pre-copy line with engine, resolved rsync
   path and forced reason; the rsync path keeps its `rsync -av` invocation and
   output; no per-file output and no entry counts on the fallback path. The
   counts of the former recommendation are gone from the confirmed rule too.
5. Q05 and acceptance. The delivery condition now reads adoption rather than
   publication, and the promise "at the latest when item 7 publishes" is removed.
   The acceptance section is split into "closable in cplx" and "tracked
   downstream, not closable here".
6. Q07. The manifest is now per-entry and explicit: relative path, entry type,
   regular-file bytes, mode, mtime, symlink target. Ownership is the installing
   account, stated or normalized. Hard-link topology stays the permitted
   divergence. ACLs join extended attributes and SELinux labels outside parity,
   justified by the tar flags in `pkg.sh` and in the extraction rather than by a
   claim about SELinux.
7. Q04 and Q08 kept at 4A and 8A. Q08's answer now requires the recipe to
   reproduce the Q07 manifest, normalize ownership and hard-link differences,
   compare the canary links explicitly, and retain its output as evidence. New
   acceptance lines cover stale hidden-entry deletion, the forced-fallback
   redeployment into a disposable populated prefix, and the retained equivalence
   evidence.

No change was made to the reviewed document outside those seven areas. The
`## Open questions` section was replaced through `oqm`, not edited by hand.

### Writer response for issue rsync-cp-fallback round 2

Writer response: All seven requested changes are accepted and applied. There is no disagreement
to record for this round.

Two of the corrections are worth acknowledging as writer errors rather than as
differences of view, because the reviewer's reasoning replaced something that was
simply false:

- The POSIX-only premise was inherited from the child draft and repeated without
  checking it. One reading of `install_pkg.sh` disproves it. The document now
  carries the audit and names the line numbers, and it also records that the
  umbrella's D4 rationale carries the same inaccurate justification. The writer
  did not edit the umbrella: correcting a settled decision's wording belongs to
  the umbrella owner, and the issue states the accurate contract locally so that
  nothing downstream inherits the error.
- The Q07 justification asserted that SELinux was irrelevant to the fallback. The
  reviewer was right that this is an assumption about someone else's server. The
  replacement argument is a fact about this system: the archive is created and
  extracted without `--acls`, `--xattrs` or `--selinux`, so the attributes are
  not in the staging tree for either engine to carry.

One clarification on the Q03 counts, since the round 1 recommendation is being
withdrawn rather than defended: the counts were proposed as evidence that the
fallback did something, and the reviewer is right that they do not prove the copy
completed. The manifest comparison is that evidence. The trace keeps only what a
reader cannot get elsewhere, which engine ran and why.

The boundaries stated in round 1 still hold and were not exercised: no umbrella
decision was reopened, and no implementation shape was specified.

### Reviewer focus for issue rsync-cp-fallback round 2

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer

- Recorded: 2026-08-08T23:08:10+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 2

The round 1 structure is substantially improved. Q01/Q02 now state the
non-atomic failure and recovery contract, Q03 removes the unhelpful counts, Q05
separates cplx proof from downstream adoption, Q09 adds the destructive-operation
boundary, and acceptance covers the requested validation evidence. D4 remains
settled. No additional open question is missing.

Two factual corrections still prevent convergence. The command inventory claims
to describe what `install_pkg.sh` calls today, but `mv` and `file` are absent,
`cp` is only proposed, and `od` is used at line 308 but omitted. It also mixes
Bash builtins with external host executables. Q06-D remains the right answer, but
the contract must distinguish Bash/builtins, mandatory external tools, optional
rsync, and shipped patchelf, with `cp` identified as a final-state addition.

Q07 also draws a conclusion the tar flags do not support. Omitting ACL/xattr/
SELinux options means producer metadata is not archived or restored; extraction
can still assign staging-local default ACLs and SELinux labels. `cp -a` attempts
to preserve those attributes while `rsync -a` omits `-A` and `-X`. The attributes
may remain outside parity because the current rsync contract never promised
them, but the specification must acknowledge possible staging metadata and
ground the exclusion in the existing rsync contract and supported-target runtime
validation.

### Question-by-question decisions for specification reviewer round 2

Q01-1A, Q02-2B, Q04-4A, Q05-5C, Q08-8A, and Q09-9A are accepted. Q03-3D is
accepted after replacing the impossible whole-output invariance with preservation
of the rsync invocation and its own per-entry output apart from new surrounding
diagnostics. Q06-6D is accepted after the inventory correction. Q07-7A is
accepted after replacing the false staging-metadata premise. Q09 should also
qualify its unconditional race-free wording unless design must provide a
race-resistant deletion mechanism.

### Requested changes for specification reviewer round 2

1. Correct and structure the Q06 inventory: remove `mv` and `file`, add `od`,
   identify `cp` as new, and separate builtins, mandatory host executables,
   optional rsync, and shipped patchelf.
2. Correct Q07 so missing archive metadata is not equated with missing staging
   metadata; ground the exclusion in current rsync semantics and runtime checks.
3. Reword Q03 and acceptance to preserve rsync's invocation and own output, not
   the complete install output.
4. Qualify Q09's absolute no-follow guarantee with its concurrency boundary or
   require a race-resistant design.

Disposition: changes-requested. Apply these substantive corrections and start
another automated review round; do not consolidate on this round.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-08T23:19:13+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for issue rsync-cp-fallback round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
Review round: 3

### Requestor assessment for issue rsync-cp-fallback round 3

All four round 2 requested changes are applied. Each factual claim was checked
against the source before being acted on, and all four held.

Verification of the command-inventory finding, which was the largest of the four:

- `mv` does not appear as a command anywhere in `install_pkg.sh`. The round 2
  audit picked it up from the child draft's original list and from prose.
- `file` likewise is never invoked. Every hit was a variable name, `$file_path`
  or `$root_file`, or a comment word. The round 2 audit used a word-boundary
  match over the raw file, which is exactly how both errors entered.
- `od` is invoked at line 308, `magic=$(head -c 4 "$file_path" 2>/dev/null |
  od -An -tx1 | tr -d ' \n')`, and was missing from the round 2 list.
- `cp` is never invoked by the current script. It is introduced by this fix, so
  it belongs to the final-state contract and not to the current-state audit.
- `chmod` is invoked once, at line 102, and stays in the list.
- patchelf is never a bare host call: `find_patchelf` resolves it from
  `$INSTALL_PREFIX/tools/bin`, then `$HOME/tools/bin`, then `PATH`, and the ELF
  pass is skipped with a warning when it is absent, so it is shipped rather than
  required of the host.

The metadata finding also holds. The tar flags establish only that no
producer-side metadata is transported. Extraction creates files, and a created
file can inherit a default ACL from its parent directory and take a
destination-local SELinux label from policy, which GNU `cp -a` then tries to
preserve while `rsync -a` does not. The round 2 justification inferred more from
the flags than they support.

What changed in the document:

- The opening section now presents the contract in four groups, Bash language and
  builtins, mandatory external commands, the `cp` this fix adds, the optional
  rsync, and the shipped patchelf, with `mv` and `file` removed and `od` added.
  A second correction paragraph records that the round 2 audit itself was wrong,
  and how.
- Q06 option 6D was restructured into those same four groups, and its question
  description now records all three inventory errors so the next reader sees why
  the reference entry exists.
- The confirmed rule and Q07 no longer claim the staging tree carries no
  metadata. The exclusion now rests on the existing `rsync -a` contract not
  promising `-A` or `-X`, on normal RHEL operation staying on rsync, and on this
  issue validating runtime behavior rather than metadata equality, with an
  explicit note that a future archive metadata contract reopens it.
- The trace and acceptance wording now says the `rsync -av` invocation, its own
  per-entry output, its semantics and its exit codes are unchanged, and states
  that the install's complete output does change because the engine line and the
  operation-named error text are new.
- Q09 and the confirmed rule now say "observed as" rather than "never", scope
  the guarantee to the check immediately preceding the delete, and place
  concurrent replacement of `<prefix>/<target>` outside this issue unless the
  design chooses a race-resistant deletion technique.

Whether questions are missing: none is proposed. Round 2 review found the nine
sufficient, and the four corrections were wording and premise defects inside
existing questions rather than new decisions.

Whether the options and answers are sufficient: the recommended directions are
unchanged from round 2, 1A, 2B, 3D, 4A, 5C, 6D, 7A, 8A, 9A. Only their
justifications moved. Two places where a reviewer may still want to press:

- Q07's exclusion is now openly a tolerated divergence rather than a proof of
  equality. If the reviewer considers that a supported-target runtime check is
  not enough evidence, the alternative is to add a label check on RHEL to
  acceptance, which the writer did not add because normal RHEL operation never
  runs the fallback.
- Q06's inventory has now been wrong twice and corrected twice. The writer's
  position is that this is the argument for recording it in the reference rather
  than in prose, but the reviewer may reasonably ask for the wiki entry to be
  produced and checked as part of this issue rather than described by it.

### Change summary for issue rsync-cp-fallback round 3

Changes since round 2, mapped to the four requested changes of the round 2
answer.

1. Command inventory, corrected and structured. The opening section now lists
   four distinct groups instead of one flat list: the Bash language and its
   builtins (`shopt`, arrays, `[[`, `local`, `source`, `command -v`, `printf`,
   `echo`, `cd`, `exit`); the mandatory external commands invoked today (tar,
   find, grep, sed, xargs, sort, head, cut, od, tr, basename, dirname, readlink,
   ln, rm, mkdir, chmod, touch); `cp` as the mandatory command this fix adds to
   the final state, explicitly not something the script calls today; rsync as
   optional and preferred; and patchelf as shipped rather than required of the
   host, with its `find_patchelf` resolution order. `mv` and `file` are gone,
   `od` is in. The same four groups now appear in Q06 option 6D and in the wiki
   update named by the gap list.
2. Metadata premise, replaced in both places it appeared. The confirmed rule and
   Q07 now say that the archive transports no producer-side metadata, that
   extraction can nonetheless create target-local ACLs and SELinux labels, that
   `cp -a` tries to preserve them while `rsync -a` enables neither `-A` nor
   `-X`, and that the exclusion therefore rests on the existing rsync contract
   and on this issue validating runtime behavior. The sentence claiming the
   staging tree carries none is removed. A future archive metadata contract is
   named as reopening the exclusion.
3. Output-invariance wording, reconciled with the new diagnostics. The confirmed
   rule, the Q03 option 3D text and its pro, the RHEL example and the acceptance
   line now scope the invariant to the `rsync -av` invocation, its own per-entry
   output, its copy semantics and its exit codes, and state that the install's
   complete output changes because the engine line and the operation-named error
   text are new.
4. Concurrency boundary, added to Q09 and to the confirmed rule. Both now read
   "observed as a symlink or non-directory immediately before deletion", scope
   the delete to the path derived from the installer's own arguments, and place
   concurrent replacement of that path outside this issue unless the design
   adopts a race-resistant deletion technique. Q09 gained a pro for the honest
   scoping and a con naming the carve-out as a real if narrow hole, and the
   acceptance line carries the same qualification.

A second correction paragraph was added to the opening section recording that
the round 2 audit itself was wrong on `mv`, `file`, `od` and `cp`, and why the
word-boundary match produced those errors.

No recommended answer changed this round: 1A, 2B, 3D, 4A, 5C, 6D, 7A, 8A and 9A
all stand, with corrected justifications. Nothing was changed outside the four
requested areas, and the `## Open questions` section was replaced through `oqm`
rather than edited by hand.

### Writer response for issue rsync-cp-fallback round 3

Writer response: All four requested changes are accepted and applied. No disagreement to record.

Three of them corrected writer errors rather than settling differences of view,
and the pattern is worth naming because it is the same pattern twice:

- The command inventory was wrong in round 1 by inheritance, taken from the child
  draft without checking, and wrong again in round 2 by method, produced with a
  word-boundary match over the raw file that counted `$file_path` as the `file`
  command and comment prose as invocations. The corrected list was built by
  looking at command positions in the comment-stripped script and by reading the
  specific lines. That is also why the writer now argues for putting the
  inventory in the wiki reference: prose copies its own errors forward, twice
  over in this document's case.
- The Q07 metadata premise was an inference the tar flags do not support. "No
  metadata is transported" is what the flags prove; "the staging tree carries
  none" is a different statement, and extraction can create both default ACLs and
  policy labels. The reviewer's replacement ground, that `rsync -a` never
  promised those attributes, is both true and sufficient, and it has the further
  merit of surviving a future change to the packaging, which the writer's version
  would not have.
- The byte-identical claim was self-contradictory in a document that also
  requires a new engine line. Scoping the invariant to the rsync command rather
  than to the install's whole output is the only reading that can be true.

On the fourth, the Q09 concurrency scope, the writer accepts the correction and
notes the tradeoff it makes explicit: the requirement now admits a narrow
time-of-check-to-time-of-use window rather than promising a guarantee the obvious
implementation could not honour. If the reviewer would rather close it than name
it, that is a design obligation (a race-resistant deletion technique) and the
requirement should say so explicitly instead of leaving it to the plan; the
writer did not assume that obligation unasked.

The boundaries stated in round 1 still hold and were not exercised: no umbrella
decision was reopened, and no implementation shape was specified. The umbrella's
D4 rationale still carries the inaccurate "only POSIX tools" phrasing; the issue
records the accurate contract locally, and correcting the umbrella remains its
owner's call.

### Reviewer focus for issue rsync-cp-fallback round 3

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by human

- Recorded: 2026-08-09T09:31:33+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: escalation

exchange was abandoned while waiting for reviewer

<!-- review-entry-id: escalation-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-09T09:32:55+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 3

All four round 2 corrections are present and coherent. Q03, Q07 and Q09 now
carry the required scopes, the inventory distinguishes its major categories,
and no additional open question is missing.

One substantive Q06 defect remains. Line 437 runs
`tar -xzf "$LATEST_ARCHIVE"`; GNU tar's `-z` option filters through and invokes
the external `gzip` program. A host-tool contract must include subprocesses
selected by command options, not only bare command-position tokens. Omitting
`gzip` leaves the target-image prerequisite list incomplete.

### Question-by-question decisions for specification reviewer round 3

Q01-1A, Q02-2B, Q03-3D, Q04-4A, Q05-5C, Q07-7A, Q08-8A and Q09-9A are accepted.
Q06-6D is accepted after adding `gzip` and documenting the subprocess-aware
inventory rule. As wording polish, Q09 should say "symlinked destination" rather
than "symlinked prefix".

### Requested changes for specification reviewer round 3

1. Add `gzip` to the opening contract, Q06-D and its answer, and the intended
   wiki update, explaining its use by `tar -xzf`.
2. State that inventory covers option-selected subprocess dependencies as well
   as shell command tokens.
3. Apply the Q09 `prefix` to `destination` wording correction.

The missing decompressor is a real bare-target prerequisite, not word polishing.
Disposition: changes-requested. Apply the correction and start another automated
review round; do not consolidate on this round.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-09T09:48:06+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for issue rsync-cp-fallback round 4

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
Review round: 4

### Requestor assessment for issue rsync-cp-fallback round 4

The single round 3 requested change is applied, together with the two supporting
items. The finding was verified against the script before being acted on, and it
held.

Verification of the `gzip` finding:

- `install_pkg.sh` contains exactly one tar invocation, line 437,
  `tar -xzf "$LATEST_ARCHIVE" -C "$STAGING_DIR"`.
- GNU tar's `-z` does not decompress in-process: it filters the archive through
  the external `gzip` program, looked up on `PATH` and run as a subprocess. A
  bare target without `gzip` therefore fails at extraction, which is the
  installer's first real action, before any of this issue's own work runs.
- No other option in the script implies a compressor or an external filter: the
  remaining `-z` matches are `[ -z "$var" ]` string tests, and there is no `-j`,
  `-J`, `--gzip`, `--xz`, `zcat` or `gunzip` anywhere.

So `gzip` is the only subprocess dependency of this kind, and the corrected
inventory is now complete on the evidence available.

What changed in the document:

- `gzip` added to the mandatory external group in the opening section, with the
  reason stated at its line number, and added to Q06 option 6D and its answer,
  and to the intended wiki update in the gap list.
- The inventory method is now recorded beside the list, in the opening section,
  in option 6D and in the wiki update item: the audit covers commands appearing
  in command position and the external subprocesses that command options start,
  and a token-only scan finds only the first kind. The Q06 question description
  records that this is precisely how `gzip` escaped three successive versions of
  the list.
- Q09's third pro now reads "a symlinked destination" instead of "a symlinked
  prefix".

Whether questions are missing: none is proposed. Round 3 review found the nine
sufficient and accepted eight of the nine answers outright.

Whether the options and answers are sufficient: every recommended direction is
unchanged and now carries reviewer acceptance, 1A, 2B, 3D, 4A, 5C, 6D, 7A, 8A,
9A. Only Q06 moved this round, and only to add the missing entry and the method.

One point the reviewer may want to weigh, since it is the fourth correction to
the same list. The inventory has now been wrong in every published version: eight
POSIX commands in round 1, `mv` and `file` wrongly present and `od` absent in
round 2, `cp` misfiled as current-state in round 2, and `gzip` missing until
round 3. Three of those four were method failures rather than oversights. The
writer's position is that this is the argument for option 6D as chosen, a list
in the reference with its method recorded beside it, rather than an argument for
abandoning the contract as option 6A would. The reviewer may reasonably take the
opposite reading, that a list this often wrong should be produced and checked as
a deliverable of this issue rather than described by it, which is the question
raised in round 2 and not yet answered either way.

Process note, for the record rather than for review. The round 3 request expired
its lease overnight and the exchange escalated at 09:31:33 before the reviewer's
answer landed at 09:32:55, about ninety seconds later. The human identified the
answer as the authoritative evidence. No reclaim was attempted, and the
resolution path proved unnecessary: publishing the answer had already returned
the exchange to answer-pending, so the ordinary consume and continue applied.

### Change summary for issue rsync-cp-fallback round 4

Changes since round 3, mapped to the three requested changes of the round 3
answer.

1. `gzip` added to the mandatory external host-tool contract, in all four places
   the contract appears: the opening section's mandatory group, Q06 option 6D,
   the Q06 answer, and the intended wiki update in the implementation gap list.
   Each states the reason rather than just the name: line 437 runs
   `tar -xzf "$LATEST_ARCHIVE"`, and GNU tar's `-z` filters through the external
   `gzip` program, which it looks up on `PATH` and runs as a subprocess, so a
   bare target without it fails at extraction.
2. The inventory method recorded, in the opening section as its own paragraph, in
   option 6D, and in the wiki update item. It states that the audit covers two
   kinds of dependency, commands in command position and external subprocesses
   implied by command options, that a token-only scan finds only the first, and
   that `tar -xzf` is the only case of the second kind in this script, which
   holds one tar invocation and no other option implying a compressor or filter.
   The Q06 question description now records the `gzip` omission alongside the
   round 2 corrections, with its structural cause.
3. Q09 option 9A's third pro reworded from "a symlinked prefix" to "a symlinked
   destination".

Nothing else moved. No recommended answer changed: 1A, 2B, 3D, 4A, 5C, 6D, 7A,
8A and 9A all stand, and only Q06's option text, answer and description were
edited. The `## Open questions` section was replaced through `oqm` rather than
edited by hand.

Two changes landed between the round 3 request being rendered and this one, both
outside the reviewed document and both reported in the round 3 writer response as
pending the umbrella owner's call. They have since been made:

- the umbrella's D4 outcome now reads "needing only host commands both supported
  targets carry", with a dated correction recording the old "only POSIX tools"
  wording, why it was wrong, and that the decision itself is unaffected;
- the child draft's bootstrap paragraph and its D4 reasoning bullet carry the
  same dated correction, and the paragraph now points at this requirement as
  authoritative while remaining the record of how the topic opened.

The reviewed document is unaffected by those two edits; they remove the source of
the claim it had already corrected locally.

### Writer response for issue rsync-cp-fallback round 4

Writer response: The round 3 change is accepted and applied. No disagreement to record.

The `gzip` finding is the most useful correction of the four rounds, and worth
naming as such. The previous three inventory errors were failures of care that
better reading would have caught. This one was not: the audit was rebuilt from
command positions in the comment-stripped script, which is the right method for
finding what a shell script invokes, and it still could not see `gzip`, because
`gzip` is not invoked by the script at all. It is invoked by `tar`, on the
strength of one option letter. No amount of care applied to the same method would
have found it, which is exactly why the method is now recorded beside the list
rather than left implicit. That is the reviewer's point, and it is a better one
than the correction itself.

The writer checked the finding's scope as well as its truth, and reports the
result rather than only the fix: `install_pkg.sh` holds exactly one tar
invocation and no other option implying a compressor or an external filter, so
`gzip` is the only dependency of this kind. If the reviewer knows of a class of
implied subprocess the writer has not thought to look for, naming it would be
more valuable than another pass over the same script.

On the standing question from round 2, whether the wiki entry should be produced
and checked inside this issue rather than described by it: the writer has not
acted on it, since it was raised as an observation rather than as a requested
change, and it would widen the item. Four wrong versions of this list is a fair
argument for doing so, and the writer would accept that direction if the reviewer
makes it a request.

The boundaries stated in round 1 still hold: no umbrella decision was reopened,
and no implementation shape was specified. The umbrella and child-draft
corrections flagged in the round 3 response have now been made by their owner's
instruction, and are described in the change summary.

### Reviewer focus for issue rsync-cp-fallback round 4

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-09T09:58:52+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 4

The round 3 correction is complete. `gzip` is present in every host-tool
contract location, the audit method includes option-selected subprocesses, and
Q09's wording is corrected. An independent audit of `install_pkg.sh` and its
canonical sourced helper found no further missing host program.

No question is missing. Q01-1A, Q02-2B, Q03-3D, Q04-4A, Q05-5C, Q06-6D,
Q07-7A, Q08-8A and Q09-9A are accepted. The wiki inventory is already an
explicit deliverable in Q06-D and implementation gap item 6; the plans should
retain and validate that work, but the requirement needs no further edit.

No specification change is requested. Disposition: convergence-recommended.
Present `Consolidate` and `Revise and review again` at the human gate.

<!-- review-entry-id: answer-round-4 -->

## Round 4 by human

- Recorded: 2026-08-09T16:32:26+02:00
- Exchange: specification/issue/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-4 -->
