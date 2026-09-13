# Specification review transcript for v0.27.0

- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md

This append-only transcript records completed review rounds. Review agents add
new entries through the review-exchange core and do not reread earlier entries
as working context.

## Round 1 by requestor for requestor round 1

- Recorded: 2026-08-09T16:41:37+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 1 (exchange 1)

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 1

### Requestor assessment for design-specification rsync-cp-fallback round 1 (exchange 1)

The design answers the settled requirement
`issue.v0.27.0.rsync-cp-fallback.md`, whose nine clarifications are recorded in
its "Requirement clarifications" table after four review rounds. Those are
inputs here, not subjects: what the fallback must reproduce, that a validation
override exists, that exit codes 5 and 7 stay, and what the equivalence manifest
contains are not reopened.

The document stays at design level: scope with explicit deferrals, confirmed
facts read from the codebase with line numbers, current and target flow, five
design areas, and acceptance cases. No file-by-file task list and no rollout
steps, which belong to the plan.

Six open questions are placed, all design-level: structure (Q01), the
equivalence contract's boundary (Q02), where a safety rule applies (Q03), an
interface consumed by another repository (Q04), a boundary condition (Q05), and
sequence placement (Q06).

Whether questions are missing. Three areas were considered and deliberately not
asked, and the reviewer should confirm each exclusion:

- Anything settled by the requirement's clarification table, which would be a
  question at the wrong altitude.
- The shape of the copy commands themselves, which is implementation.
- The wiki entry's wording, which the requirement already fixed as a deliverable
  with its four groups and its recorded method.

Whether the existing options and answers are sufficient. Q02 deserves the most
scrutiny, because it is the one question that came out of writing the design
rather than out of the requirement, and it reports a divergence nobody has
measured on this tree yet. The claim is that `rsync -av --delete src/ dst/`
applies source metadata to the transfer root while a fallback that empties an
existing `dst` and copies content into it leaves `dst` with its own mode and a
fresh mtime. If that reading is right, a manifest that includes the destination
root reports a divergence on every run, and the recommended answer excludes it.
If the reading is wrong, option 2A weakens the comparison for no reason. This is
worth checking against real behavior rather than accepting on argument.

Q03 is the other one with a genuine cost either way. It leaves the installer
refusing a symlinked `<prefix>/<target>` on the fallback path while rsync
accepts it, so the same misconfiguration behaves differently on the two
supported targets. The recommendation keeps the asymmetry to protect the
invariant that the rsync path is unchanged, and asks that the asymmetry be
stated rather than left to be discovered. A reviewer who values uniform
behavior over that invariant would answer 3B, and that is a legitimate
disagreement rather than an error.

Q05 proposes a new failure path for a case never observed, on the argument that
its failure is silent. If the reviewer thinks the case cannot arise, the honest
alternative is 5B, and the question then becomes whether a silent misplacement
is acceptable when it cannot happen.

Two points on the design body rather than on its questions:

- The confirmed-facts section asserts that GNU tar `-z` runs the external `gzip`
  binary and that `pkg.sh` packs without ACL, xattr or SELinux flags. Both were
  checked during the requirement review, and both matter to the design's
  metadata exclusion, so they are the facts to challenge first if any of them is
  wrong.
- The design states the non-atomicity recovery as something the script already
  does (staging retained on failure, old staging cleared before the next
  extraction) rather than as new behavior. If that reading of the current script
  is wrong, the recovery half of Q01's requirement-level answer becomes new work
  and the design understates its scope.

### Change summary for design-specification rsync-cp-fallback round 1 (exchange 1)

Round 1 for this design, so there is no preceding round to compare against. The
document was written in this cycle, directly after the requirement settled.

Its inputs:

- `issue.v0.27.0.rsync-cp-fallback.md`, consolidated after four review rounds,
  whose "Requirement clarifications" table carries the nine settled decisions
  with the alternatives each rejected;
- `draft.v0.27.0.debian-agent-tools.md`, the umbrella, for the two-distribution
  constraint and for decision D4;
- `src/setups/env/bin/install_pkg.sh` and `src/setups/env/bin/pkg.sh`, read for
  the confirmed-facts section;
- `wiki/reference/relocation-tools.md` and `wiki/reference/exit-codes.md`, for
  the published exit contract this design preserves.

Structure written: context, scope with three outcomes and five explicit
deferrals, seven confirmed facts each tied to why it constrains the design,
current and target flow as call chains, five design areas (engine selection,
mirror semantics, failure and diagnostic contract, equivalence and validation
model, documented contract), and nine acceptance cases.

Everything the design asserts about the current script is sourced: the two call
sites and their fatal codes, the `fix_home_symlink_targets` call that consumes
the mirrored tree, the `echos` helper resolution, the Bash and GNU dependencies
with line numbers, the `gzip` subprocess behind `tar -xzf`, the tar flags on
both the packing and extraction sides, and the existing staging-retention
behavior on failure.

Six open questions were added through `oqm` after the body was written, so the
body reflects the recommended answers where they touch it, and the questions
record the alternatives rather than leaving the body ambiguous.

### Writer response for design-specification rsync-cp-fallback round 1 (exchange 1)

Writer response: No reviewer feedback exists yet: this is the first request of the design
exchange, so nothing has been accepted, adapted or disputed.

Three boundaries the writer intends to hold, stated up front so a disagreement
can be raised in the first answer rather than in a later round:

- The nine requirement clarifications are settled and are not reopened at design
  level. A reviewer point that would change what the fallback must reproduce,
  whether the override exists, which exit codes are used, or what the
  equivalence manifest contains belongs to the requirement, and the writer will
  say so rather than absorbing it here.
- Implementation shape is out of scope. Which shell constructs perform the copy,
  how helper functions are factored, and the exact command lines belong to the
  plan that follows.
- The rsync path's invariance is the design's load-bearing constraint, not a
  preference. Several questions could be answered more tidily by changing what
  rsync does, and the writer will resist those on the ground that RHEL adoption
  without a production validation campaign depends on that path being untouched.

Everything else is open, including all six recommended answers, the five
deferrals, and whether the design areas are cut at the right joints.

One request rather than a defense. The requirement review found four factual
errors in four rounds, three of them method failures rather than oversights, and
every one was caught by the reviewer rather than by the writer. The most useful
thing this round can do is the same again: the confirmed-facts section and the
Q02 metadata claim are the two places where a wrong fact would propagate
silently into the plan, and they are worth checking against the code and the
tools rather than against the argument.

### Reviewer focus for design-specification rsync-cp-fallback round 1 (exchange 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by human for human round 1

- Recorded: 2026-08-09T19:42:12+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: escalation

exchange was abandoned while waiting for reviewer

<!-- review-entry-id: escalation-round-1 -->

## Round 1 by reviewer

- Recorded: 2026-08-09T20:06:16+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for design-specification reviewer round 1

The current design has five live questions; Q02 was withdrawn after the request
was rendered, and its measured transfer-root correction is accepted. The core
design preserves the settled requirement, but two substantive defects remain.

Q04 calls the override name and value a cross-repository interface without
selecting either. Fix both at design level; the recommended contract is
`CPLX_INSTALL_PKG_FORCE_CP=1`, with only exact `1` forcing the fallback.

Q05 rests on an incorrect `cp` premise. `cp -a file prefix/` computes
`prefix/<basename>` and fails when that entry is a directory or symlink to one;
it does not silently nest the file. Reframe Q05 from measured behavior for both
engines and scope any added wrong-type boundary to the fallback so rsync stays
unchanged. Q03 should likewise stop claiming rsync accepts every symlinked or
non-directory mirror destination.

Q01-1A and Q06-6A are accepted with wording corrections. Q03-3A is accepted
after its factual correction. Q04 and Q05 need replacement options. No new
question is needed.

Disposition: changes-requested. Correct the interface and wrong-type behavior,
then start another automated design review round; do not consolidate yet.

<!-- review-entry-id: answer-round-1 -->

## Round 2 by requestor for requestor round 2

- Recorded: 2026-08-09T20:20:47+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 2 (exchange 1)

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 2

### Requestor assessment for design-specification rsync-cp-fallback round 2 (exchange 1)

Five questions are live: Q01, Q03, Q04, Q05 and Q06. Q02 is not a question and
is not counted as one: it was withdrawn before any answer, on the two-target
measurement recorded in the umbrella, and the preamble records it as a settled
premise with its number left vacant so the transcript stays readable.

All five round 1 requested changes are applied.

The two substantive findings were checked rather than accepted on authority, and
both held:

- Q04's interface really was underspecified. "A name in the project's convention"
  and "one affirmative value" is not an interface, and a variable read by a
  Jenkins stage and by another repository's deployment script would have been
  agreed twice. It is now fixed at design level, in the body, in the question and
  in the acceptance cases: `CPLX_INSTALL_PKG_FORCE_CP=1`, only the exact value
  `1` forcing the fallback, anything else behaving as unset. The option's pro is
  reworded: other values fail safe by leaving rsync selected and stay visible
  through the selected-engine trace, rather than "failing loudly".
- Q05's premise was false. The feared silent nesting does not occur: GNU `cp`
  treats the trailing-slash operand as the target directory, computes
  `$INSTALL_PREFIX/<basename>`, and refuses to overwrite a directory with a
  non-directory. The question is rewritten around what is actually at stake, the
  quality of the diagnostic and the unknown rsync half, and option 5A is now
  justified as making an already-correct refusal legible and consistent with the
  operation-named failures the rest of the design pays for, scoped to the
  fallback so the rsync path stays untouched.

Q03's premise is corrected in the same spirit: the claim that rsync accepts
every symlinked or non-directory destination is gone, replaced by the two cases
that differ, a regular-file destination failing under a trailing slash and a
symlink to a directory being the shape that may be followed. The 3A direction is
unchanged and its cons now name what is unknown rather than asserting it.

The Q01 duplication wording and the no-`gzip` acceptance wording are corrected.

What this round adds, and the reason it is worth a reviewer's attention: three
measurements are now stated in the design as work it owes, rather than as
assertions. M1 records what rsync does per destination shape on the supported
RHEL version, which is the rsync half of Q03. M2 records both engines' behavior
per root-file destination shape, which is the half of Q05 that review round 1
established is unknown. M3 records whether a real deployment prefix is ever a
symlink, which is the evidence Q03's cost assessment has lacked from the start
and which cannot be obtained anywhere but on a real target.

The reviewer should judge two things about them. First, whether M1 and M2 as
specified would actually settle Q03 and Q05, or whether a shape is missing from
either matrix. Second, whether stating them as owed measurements is the right
design-level move, or whether a design should assert a behavior and let the plan
verify it. The writer's position is the former, on the evidence of this effort:
of the claims this pair of documents has made about tool behavior, the ones that
were measured have held and the ones that were argued have not.

One caveat the reviewer may want to weigh. M1 and M2 are cheap and can be taken
before implementation, but M3 depends on access to a real deployment prefix. If
that access does not materialize, Q03 keeps its recommendation and its unknown
cost, and the design should say so rather than leaving the reader to assume the
measurement happened.

### Change summary for design-specification rsync-cp-fallback round 2 (exchange 1)

Changes since round 1, mapped to the five requested changes of the round 1
answer.

1. Q04 now selects an exact interface, `CPLX_INSTALL_PKG_FORCE_CP=1`, with only
   the value `1` forcing the fallback and any other value behaving as unset.
   Applied in three places: the engine-selection design area, the question's new
   option 4D with the old 4A kept and marked rejected, and the acceptance cases,
   which gained a row for a non-`1` value being treated as unset with rsync
   selected and reported.
2. Q05 is rewritten. Its question description now records that the silent-nesting
   premise was disproved and how; its options are re-scoped to a fallback-only
   wrong-type boundary with rsync left unchanged; and its recommendation and
   answer are re-argued as diagnostic quality rather than safety. Measurement M2
   is named as the source for the behavior matrix it depends on.
3. Q03's description no longer claims rsync accepts every symlinked or
   non-directory destination. It separates the regular-file case from the
   symlink-to-directory case, and its option 3A cons now say which difference is
   known and which awaits M1. The mirror-semantics design area carries the same
   correction. The 3A direction is unchanged.
4. Q01's con is reworded: the duplicated part is the engine branch and its
   failure handling, not selection or the once-per-run trace. The no-`gzip`
   acceptance case now reads "before any transfer" rather than "before this
   work's code runs".
5. The questions preamble opens by naming the five live questions, and this
   request reports five rather than six.

New in this round, beyond the requested changes:

- A design section, "Measurements this design still owes", specifying M1
  (rsync mirror destination per shape on the supported RHEL version), M2 (both
  engines' root-file destination per shape) and M3 (whether a real deployment
  prefix is ever a symlink). Each states what it settles and why it cannot be
  argued instead.

Unrelated to the review, applied to the versioned documents in the same pass:
the repository's own sensitive-term rules were applied to `docs/`. One reference
in the requirement used the private project's real name and now uses its
`my-project` alias, matching the umbrella; the two review transcripts carried an
operating-system account name inside absolute paths and now carry its `vonc`
alias. No document content changed beyond those substitutions.

### Writer response for design-specification rsync-cp-fallback round 2 (exchange 1)

Writer response: All five requested changes are accepted and applied. No disagreement to record.

Two of them corrected writer errors rather than differences of view, and the
second is the more interesting:

- Q04 described an interface instead of fixing one. The reviewer is right that
  this is not a design-level answer at all: the whole reason the question exists
  is that a Jenkins stage and another repository's deployment script both have
  to spell the same thing, and a description leaves them to agree separately.
- Q05 rested on a behavior GNU `cp` does not have. The question was written
  around silent nesting, and `cp` refuses instead. The honest consequence is not
  that the question dies but that it shrinks: what is left is diagnostic quality,
  an installer that fatals with its own step name and exit code rather than
  leaking `cp: cannot overwrite directory ...` behind a bare non-zero status.
  The rewritten answer claims only that.

That is the third premise in this effort to be settled by checking a tool rather
than by reasoning about it, after the POSIX contract and the transfer-root
metadata. The design now names three measurements it owes rather than asserting
what it has not measured, and the writer would rather be told a shape is missing
from M1 or M2 than be agreed with.

One request that the reviewer is better placed to answer than the writer. M3
asks whether any real deployment prefix has `<prefix>/tools` as a symlink. It is
one `ls -ld` on a real target, and it is the only evidence that would let Q03
state its cost instead of admitting it is unknown. If that access is not
available, say so, and the design will record the gap explicitly rather than
leaving a reader to assume the measurement was taken.

The boundaries stated in round 1 still hold: the nine requirement clarifications
are not reopened, implementation shape stays out of the design, and the rsync
path's invariance is treated as a constraint rather than a preference, which is
why both new boundaries are scoped to the fallback.

### Reviewer focus for design-specification rsync-cp-fallback round 2 (exchange 1)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer for reviewer round 2

- Recorded: 2026-08-09T23:46:55+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 2

The completed M1, M2 and M3 measurements resolve the factual uncertainty that
justified this round, and the retained raw outputs are sufficient to review the
design without another measurement cycle. They support Q03-3A and the direction
of Q05-5A, but they also show that the current design gives both questions an
obsolete factual basis. This is a design-level defect because the measured
hazards determine which destination shapes the fallback may safely accept.

M1 shows that rsync follows a mirror destination that is a symlink to a
directory and, under `--delete`, empties the external target while returning 0.
It refuses a regular file, a symlink to a regular file and a FIFO, and fails on
a dangling symlink. M3 inspected one real RHEL deployment prefix: its `tools`
entry is a real directory, not a symlink, and carries an extended ACL. This
supports Q03-3A's fallback-only boundary while making its asymmetry precise:
the fallback refuses a symlink-to-directory shape on which the unchanged rsync
path can delete outside the apparent destination. Other deployment prefixes
remain uninspected, so M3 does not establish that this shape never occurs.

M2 changes Q05 more substantially. Rsync replaces an empty directory with the
file and returns 0, but refuses a populated directory with exit 23 and leaves it
intact; `cp` refuses both directory shapes with exit 1. Against a destination
that is a symlink to a regular file, rsync replaces the link and leaves its
target untouched, whereas GNU `cp` follows the link, overwrites the external
target and returns 0. Against a FIFO, `cp` blocks; the recorded 124 is the probe
timeout after twenty seconds, not a copy-engine failure. The same copy verdicts
on coreutils 8.32 and 9.1 show that these are fallback-engine semantics rather
than a distribution accident. Consequently Q05-5A is a safety boundary, not
merely a diagnostic improvement.

### Measurement answers

The complete matrices below are taken from
`docs/v0.27.0/measurements.index.md`. Their individual rows can be checked
against the corresponding `--- M1 case:` and `--- M2 engine` blocks in the raw
outputs retained beside that index.

#### M1: `rsync -av --delete src/ dst/`, nine destination shapes

Measured on RHEL 9.8 with rsync 3.2.5. The Debian target has no rsync, so M1 is
unavailable there.

| Destination shape | Exit | Destination after | External target | Outcome |
| --- | --- | --- | --- | --- |
| absent | 0 | directory | n/a | created, mirrors the source |
| empty real directory | 0 | directory | n/a | mirrors the source |
| populated real directory | 0 | directory | n/a | mirrors the source; the three stale entries are deleted |
| regular file | 3 | regular file | n/a | refused with `cannot stat destination`; destination untouched |
| symlink to empty directory | 0 | symlink, followed | changed | writes through the link into the external directory |
| symlink to populated directory | 0 | symlink, followed | changed | writes through the link and deletes the external content |
| symlink to regular file | 3 | symlink, followed | unchanged | refused with `cannot stat destination` |
| dangling symlink | 11 | symlink, followed | n/a | refused with `mkdir failed: File exists` |
| FIFO | 3 | FIFO | n/a | refused with `cannot stat destination` |

The three real-directory shapes all succeed and mirror the source. The
destructive case is a symlink to a populated directory: rsync returns 0 while
deleting content in the external target.

#### M2: `rsync -av file prefix/` and `cp -a file prefix/`, eight shapes

Both engines and every shape were measured on RHEL 9.8. The shape is that of
`prefix/<basename>` before the engine runs.

| Prefix entry shape | rsync exit | rsync result | cp exit | cp result |
| --- | --- | --- | --- | --- |
| absent | 0 | file created | 0 | file created |
| regular file | 0 | overwritten in place | 0 | overwritten in place |
| empty directory | 0 | directory replaced by the file | 1 | refused; directory intact |
| populated directory | 23 | refused; directory intact | 1 | refused; directory intact |
| symlink to directory | 0 | link replaced by the file; target untouched | 1 | refused; link and target intact |
| symlink to regular file | 0 | link replaced by the file; target untouched | 0 | link retained; external target overwritten |
| dangling symlink | 0 | link replaced by the file | 1 | refused; link intact |
| FIFO | 0 | FIFO replaced by the file | 124 | blocked and killed after 20 seconds; FIFO intact |

The engines agree on two shapes of eight. Rsync replaces what `cp` refuses on
five shapes. On a symlink to a regular file both return 0 but have opposite
effects: rsync replaces the link and preserves the external target, while `cp`
retains the link and overwrites that target. Debian 12 with coreutils 9.1
reproduced the entire RHEL coreutils 8.32 `cp` column, so no M2 copy result is
version-sensitive across the supported targets.

#### M3: `<prefix>/tools` on real deployment prefixes

| Prefix | `<prefix>/tools` | Mode | Symlink |
| --- | --- | --- | --- |
| `/home/<account>` | real directory | `drwxrwxr-x+`, extended ACL | no |

Exactly one prefix was inspected. Its `tools` entry is a real directory; every
other prefix remains uninspected. The trailing `+` records an extended ACL.

The phrase "regular file or absent" must also be made unambiguous: the
destination type must be observed without following a symlink. A following
regular-file predicate would classify a symlink to a regular file as acceptable
and preserve exactly the measured overwrite hazard. The design need not select
a shell construct, but it must require a non-following type observation and
refuse every symlink and special file before invoking `cp`. In particular, the
FIFO refusal must be pre-copy and prompt so the installer cannot hang.

Question decisions:

- Q01: accept option 1A. The measurements do not alter the structural reason to
  keep mirror and root-file transfer paths independent.
- Withdrawn Q02: accept the withdrawal. The retained transfer-root probes
  confirm that `cp -a src/. dst/` applies the source root's mode and mtime to the
  destination root and carries hidden entries, so no manifest carve-out or
  alignment step is needed.
- Q03: accept option 3A after replacing its unknown and tentative statements
  with the measured M1 matrix and the one-prefix scope of M3. The rsync path
  remains unchanged; the fallback boundary refuses any mirror destination that
  is present but is not a real directory.
- Q04: accept option 4D, including the exact
  `CPLX_INSTALL_PKG_FORCE_CP=1` interface and exact-value rule.
- Q05: accept option 5A's fallback-only scope, but require the safety rationale
  and non-following destination-type contract above. The accepted shapes are
  absent or an existing real regular file; directories, every kind of symlink,
  FIFOs and other special files fail the root-file step with exit 7 before
  copying. The unchanged rsync path retains its measured behavior.
- Q06: accept option 6A. Decide and announce the selected engine once before
  archive search.

No additional open question is needed. The following changes are required
before consolidation:

1. Replace "Measurements this design still owes" with retained measurement
   evidence and its design consequences. Cite `measurements.index.md`, both
   destination-shape outputs, the Debian mirror-root probe and the Debian
   installer-contract probe. Record the exact M1 and M2 outcomes rather than
   continuing to call them unknown.
2. Update the mirror-semantics area and Q03 to state that rsync follows a
   symlink-to-directory mirror root and can delete its external contents with
   exit 0. Preserve 3A, and state that M3 covers one real prefix only.
3. Update the root-file area and Q05 to state the measured copy-through-symlink
   overwrite and FIFO hang. Define the fallback preflight as a non-following
   type check that accepts only absence or a real regular file. Replace every
   claim that its value is only diagnostic quality with the measured safety
   rationale.
4. Add acceptance cases proving that a root-file destination symlink to a
   regular file fails with exit 7 without changing either link or target, and
   that a FIFO fails promptly with exit 7 without starting a blocking copy.
5. Record that the inspected deployment directory has an extended ACL. This
   does not reopen the requirement's deliberate ACL exclusion, but it prevents
   the design from implying that excluded metadata is absent in production.
6. Put regeneration and durable retention of the missing RHEL
   installer-contract and transfer-root outputs into validation follow-up. Their
   absence does not block this design review because the relevant RHEL results
   are reported and the decisive destination-shape evidence is retained.

Disposition: changes-requested. Revise the design from the completed evidence
and start another automated design review round; do not consolidate yet.

<!-- review-entry-id: answer-round-2 -->

## Round 3 by requestor

- Recorded: 2026-08-10T09:55:16+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 3

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 3

### Requestor assessment for design-specification rsync-cp-fallback round 3

All six round 2 requested changes are applied, from the completed M1, M2 and M3
evidence rather than from argument. Five questions remain live: Q01, Q03, Q04,
Q05 and Q06.

The measurements did not merely confirm the design; they moved one decision's
justification and sharpened another's. That is worth stating plainly, because it
is the third time in this effort that measurement has overturned reasoning:

- **Q05 is a safety rule, not a diagnostic one.** Round 2 concluded, on what was
  then known, that a root-file boundary would only improve error messages. M2
  disproves that. Against a destination that is a symlink to a regular file,
  `cp -a` follows the link, overwrites a file the installer was never pointed
  at, and returns 0; against a FIFO it blocks, and the recorded 124 is a probe
  timeout rather than an engine failure. Both reproduce on coreutils 8.32 and
  9.1. The "diagnostic quality" justification is withdrawn from the question, the
  design body and the answer, and replaced by the measured hazards.
- **Q03's asymmetry is now the opposite of embarrassing.** M1 shows rsync
  following a symlink-to-directory mirror root and, under `--delete`, emptying
  the external target while returning 0. So the shape where the two engines
  differ is the shape where the unchanged engine is silently destructive, and the
  stricter engine is the new one. 3A is unchanged, but its case is stronger and
  its cost is now measured rather than guessed.

The non-following type observation is carried as part of the Q05 answer rather
than as an implementation note, because the obvious way to write the check is
the one that reintroduces the bug: a predicate that follows symlinks classifies
a symlink to a regular file as an acceptable regular file and preserves exactly
the measured overwrite. The FIFO refusal is required to precede any copy, since
a check that runs after `cp` opens the path has already hung.

M3's scope is stated honestly wherever it appears: one prefix inspected, its
`tools` entry a real directory, every other prefix uninspected. It narrows the
Q03 risk without establishing that the symlink shape never occurs.

The extended ACL on that inspected directory is recorded in the evidence
section, with the point the reviewer asked for: it does not reopen the
requirement's ACL exclusion, which rests on `rsync -a` never having promised
those attributes, but it does mean the excluded metadata exists in production
rather than in theory, and the design must not be read as claiming otherwise.

The two missing raw outputs, the RHEL installer-contract and transfer-root
probes, are recorded as owed to validation follow-up rather than quietly
omitted, so a later reader cannot mistake a reported result for a retained one.

What the reviewer should press on. First, whether the Q05 accepted set is right:
it admits only an absent destination or a real regular file, which means the
fallback refuses five of the eight measured shapes that rsync accepts or
replaces, and that gap is now a documented behavioral difference between the two
supported targets rather than an oversight. Second, whether recording the M1
symlink-to-directory hazard without acting on it is the correct boundary for
this item. The writer's position is that fixing rsync's behavior would break the
invariant this design exists to protect and belongs to the umbrella; a reviewer
could reasonably argue that a measured, silent, cross-boundary deletion should
not be left to a later item merely because it predates this one.

### Change summary for design-specification rsync-cp-fallback round 3

Changes since round 2, mapped to the six requested changes of the round 2
answer.

1. "Measurements this design still owes" is replaced by "Measurement evidence
   behind this design", carrying the M1 nine-shape matrix, the M2 eight-shape
   two-engine matrix and the scoped M3 result, each with its outcome recorded
   rather than described as unknown. It cites `measurements.index.md` and names
   the four retained raw files, including the Debian mirror-root and
   installer-contract probes.
2. The mirror-semantics area and Q03 now state that rsync follows a
   symlink-to-directory mirror root and, under `--delete`, empties the external
   target while returning 0, and that the fallback refuses that shape. 3A is
   preserved. M3's one-prefix scope is stated in both places.
3. A new design area, "Root-file deploy", carries the measured
   copy-through-symlink overwrite and the FIFO hang, defines the preflight as a
   non-following type check accepting only an absent destination or a real
   regular file, and requires the FIFO refusal to precede any copy. Q05 is
   rewritten on the same basis, and every claim that its value is diagnostic
   quality is removed from the question, its recommendation and its answer.
4. Two acceptance cases added: a root-file destination that is a symlink to a
   regular file fails with exit 7 with link and external target both intact, and
   a FIFO destination fails promptly with exit 7 without starting a blocking
   copy. A third row records that rsync keeps its measured behavior on those
   shapes, so the asymmetry is asserted rather than implied.
5. The extended ACL on the inspected deployment directory is recorded in the M3
   subsection, with an explicit note that it does not reopen the requirement's
   ACL exclusion but does prevent the design from implying that excluded
   metadata is absent in production.
6. The two unretained RHEL raw outputs are recorded as validation follow-up in
   their own subsection, "Evidence still owed, in validation rather than here",
   stating why their absence does not block this design.

Also updated for consistency with the above: the target-behaviour flow now shows
the root-file preflight as a pre-copy, non-following check with fatal 7, beside
the mirror's pre-delete boundary with fatal 5.

No question was added or withdrawn this round. Q01, Q04 and Q06 are unchanged
apart from Q01's already-applied wording fix; the reviewer accepted all three in
round 2.

Sensitive-term hygiene was reapplied to `docs/` after the round 2 publication,
since each transcript append reintroduces absolute paths carrying an account
name. The measurement files added this round were scanned and are clean.

### Writer response for design-specification rsync-cp-fallback round 3

Writer response: All six requested changes are accepted and applied. No disagreement to record.

The round 2 answer did something more useful than list corrections: it read the
measurements against the design and found that they invalidated the reasoning of
a decision they otherwise supported. Q05 kept its recommended option and lost its
justification. That is a distinction worth naming, because a review that only
checked whether the answer changed would have passed it.

The writer's error there is instructive and is now recorded in the question
itself. Round 1 asserted a hazard `cp` does not have, silent nesting. Round 2,
corrected, concluded there was no hazard at all and downgraded the rule to
diagnostics. Both were reasoning about a tool instead of running it. M2 shows the
real hazards were adjacent to the guessed one all along: not nesting inside a
directory, but following a symlink out of the prefix, and blocking forever on a
FIFO. The rule survives, its scope is the same, and only its reason was ever
wrong.

One point offered for the reviewer to push back on rather than defended. This
design now records, without acting on it, that the unchanged rsync path can
empty a directory outside the prefix and report success when the mirror
destination is a symlink to a directory. The writer's position is that changing
that belongs to the umbrella: acting on it here would break the invariant that
makes this item adoptable on production without its own validation campaign, and
would turn the collection's smallest item into prefix validation. But it is a
measured, silent data-loss path, and "it predates this change" is a weaker reason
than it looks. If the reviewer judges that recording it is not enough, the
writer would rather hear that now than after the plan is written.

The boundaries stated in round 1 still hold: the nine requirement clarifications
are not reopened, implementation shape stays out of the design, and both new
boundaries are scoped to the fallback so the rsync path stays untouched.

### Reviewer focus for design-specification rsync-cp-fallback round 3

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-3 -->

## Round 3 by reviewer

- Recorded: 2026-08-10T10:10:53+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 3

The completed measurement section is sufficient and the revised Q05 design now
rests on the right evidence. The non-following preflight, its accepted shapes,
the symlink-target preservation case and the prompt FIFO refusal are all
design-level constraints rather than leaked implementation choices. M3 is
scoped correctly, including its extended ACL, and the two unretained RHEL
outputs are visible validation follow-up rather than implied evidence.

Q03-3A remains the right answer for this item. The settled requirement says the
rsync invocation, per-entry output, semantics and exit codes stay unchanged;
choosing 3B here would reopen that requirement rather than finish its design.
That does not make the measured rsync behavior acceptable. A silent write or
delete through a symlinked mirror root is a separate production defect and must
become an explicit umbrella follow-up, not merely something the prose says the
umbrella may consider later.

The current Q03 text also contains four factual regressions that obscure that
decision:

1. The mirror area still says the fallback is "genuinely more dangerous than
   rsync" and describes rsync as removing only entries it knows about. M1 shows
   rsync following the directory link and changing the external target, so that
   contrast is false.
2. Q03's analogy says the rsync crew "never empties anything". M1 demonstrates
   exactly the opposite under `--delete`.
3. Option 3A says the engines diverge on three of nine shapes and calls two
   divergences harmless. At installer level they diverge on the two measured
   symlink-to-directory shapes: an initially empty external directory is
   written through, and a populated one is written through and has stale
   entries deleted. Neither is harmless merely because the target began empty.
4. The Q03 answer again says "a symlinked destination" is accepted by rsync.
   That overgeneralizes the measured result: rsync refuses a symlink to a
   regular file and a dangling symlink. The accepted class is a symlink to a
   directory.

One design question is missing. The root-file safety rule performs a
non-following observation and then invokes `cp`; concurrent replacement between
those operations can turn the checked entry into a symlink or FIFO and restore
the overwrite or hang. The scope currently defers only the analogous
check-to-delete race. Add a question deciding whether the root-file guarantee is
also observation-scoped or whether deployment must be race-resistant. The
recommended answer is to scope concurrent replacement out, matching the
settled mirror rule and the installer's controlled-prefix operating model, but
to state that limit in the deferrals, root-file area and acceptance boundary.
A race-resistant answer would require a materially different deployment
technique and should not arrive accidentally in the plan.

Two smaller corrections remain. The evidence-follow-up subsection says the
unretained RHEL results are "reported in the index"; the index records their
absence and says the results are quoted in the umbrella. State that exact
provenance. Q04's description still says the design does not name the override,
although the body and option 4D now fix it; rewrite the description in present
tense so the open question does not contradict its own accepted answer.

### Question-by-question decisions for specification reviewer round 3

1. **Q01: accept option 1A.** Keep independent mirror and root-file paths using
   one shared engine verdict.
2. **Withdrawn Q02: keep withdrawn.** The measured `cp -a src/. dst/` form
   resolves transfer-root metadata and hidden entries without a carve-out.
3. **Q03: accept option 3A after the factual corrections above.** Preserve the
   settled rsync invariance in this item, describe the two
   symlink-to-directory cases exactly, and create an explicit umbrella
   follow-up for the unchanged engine's cross-boundary write and deletion.
4. **Q04: accept option 4D.** Keep the exact
   `CPLX_INSTALL_PKG_FORCE_CP=1` interface and exact-value rule; correct only
   the stale question description.
5. **Q05: accept option 5A.** Absence or a real regular file are the only
   accepted fallback shapes; the observation must not follow symlinks and the
   FIFO refusal precedes `cp`. Add the missing concurrency-scope question.
6. **Q06: accept option 6A.** Decide and announce once before archive search.

### Requested changes for specification reviewer round 3

1. Correct the mirror-area and Q03 statements that contradict or overgeneralize
   M1, including the divergence count, the "harmless" label, the analogy and
   the final symlink wording.
2. Keep 3A for this item, but add a concrete umbrella follow-up for hardening
   rsync mirror destinations against symlink-to-directory cross-boundary writes
   and deletes. Recording the defect only inside this child design is not a
   durable backlog decision.
3. Add and answer the root-file check-to-copy race question. If the recommended
   observation-scoped answer is chosen, extend the race deferral and the
   root-file guarantee accordingly; if race resistance is chosen, describe the
   stronger deployment boundary before planning.
4. Correct the provenance of the two unretained RHEL outputs: their absence is
   recorded in the index and their results are quoted in the umbrella.
5. Reword Q04's description so it acknowledges that option 4D's exact interface
   is already incorporated in the design.

### Reviewer decision for specification reviewer round 3

Disposition: changes-requested. Q05 is now sound and the existing answers remain
the right choices, but Q03 still contradicts its measurement in several places,
the production rsync hazard lacks an explicit umbrella backlog item, and the
root-file safety guarantee omits its check-to-copy race. Apply these changes and
start another automated design review round; do not consolidate yet.

<!-- review-entry-id: answer-round-3 -->

## Round 4 by requestor

- Recorded: 2026-08-10T14:01:07+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 4

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 4

### Requestor assessment for design-specification rsync-cp-fallback round 4

All five round 3 requested changes are applied. Six questions are now live:
Q01, Q03, Q04, Q05, Q06 and the new Q07. Q02 stays withdrawn.

The new question was answered from measurement rather than from the premise it
arrived with, and that premise turned out to be half wrong. Round 3 recommended
scoping the root-file race out on the grounds that race resistance "would
require a materially different deployment technique". M4 tested it over three
copy forms and eight destination shapes on both targets, and the twenty-four
cells agree across coreutils 8.32 and 9.1:

- Two forms inside the existing host-tool contract do close two of the four
  unsafe shapes by construction. Against a symlink to a regular file,
  `--remove-destination` and copy-then-rename both leave the external target
  byte-identical with its mtime untouched, where the plain form rewrites it.
  Against a FIFO they replace it in 15 and 25 milliseconds, where the plain form
  blocks and is killed at twenty seconds. No different technique was needed for
  either.
- Two shapes defeat every form measured. A symlink to a directory is followed by
  all three, because `--remove-destination` does not unlink a link that points
  at a directory and `mv -f` renames into the directory the link points at. A
  real directory, empty or populated, swallows the payload with exit 0 under all
  three, and under the rename form it lands there under the hidden temporary
  name.

So the recommendation survives and its reason changes: the guarantee is
observation-scoped because no available form closes the window, not because
closing it would need different machinery. Q07 answers 7A and adopts
`--remove-destination` anyway, as defence in depth for the half that is
closable, at no cost to the audited inventory. The rename form is rejected on
its measured cost: it needs `mv`, which the installer does not invoke today, and
it strands a hidden temporary file on the shape where its rename fails.

One correction the measurement forced, which the design now records because it
would otherwise mislead the plan. M2 and M4 disagree on the real-directory shape
only because they measured different commands: the target-directory spelling
refuses with exit 1, the explicit-name spelling nests with exit 0. That is two
commands, not a contradiction, and the explicit-name spelling is the less safe
one. The preflight makes both safe, which is now the strongest argument for
keeping it.

The four other round 3 changes: Q03's factual regressions are corrected in the
mirror area, the analogy, the divergence count and the final wording; the
umbrella carries the rsync cross-boundary hazard as its own dated follow-up
section rather than as prose inside this design; the two unretained RHEL outputs
are described with their exact provenance, absent from the index and quoted in
the umbrella; and Q04's description is rewritten in present tense so it no
longer contradicts its own accepted answer.

What the reviewer should press on. First, whether 7A's residual is stated
sharply enough to be actionable: with the preflight and `--remove-destination`,
a concurrent swap to a symlink to a regular file or a FIFO is handled and a swap
to a real directory or a symlink to one is not, and that asymmetry is now the
whole of the deferred risk. Second, whether adopting a copy-form flag belongs in
a design at all, given that this document has otherwise refused to name shell
constructs. The writer's position is that M4 makes it a design-level property in
the same way the mirror's `src/.` form is: the flag changes which hazards exist,
not merely how the code reads.

### Change summary for design-specification rsync-cp-fallback round 4

Changes since round 3, mapped to the five requested changes of the round 3
answer.

1. Q03's four factual regressions corrected. The mirror area no longer says the
   fallback is more dangerous than rsync, nor that rsync removes only entries it
   knows about; it states the measured behavior and says the rule exists because
   the fallback's delete is unbounded if misdirected, not because rsync is
   careful. The analogy's established crew now walks to the other building and
   clears a room there. Option 3A's con names the two symlink-to-directory
   shapes exactly, writes out what happens in each, and drops the "harmless"
   label. The answer says "a symlink to a directory" rather than "a symlinked
   destination", since rsync refuses a symlink to a regular file and fails on a
   dangling one.
2. The umbrella gained a dated follow-up section, "Follow-up raised by
   requirement 1, to schedule in this collection", recording the measured
   cross-boundary write and delete, that it is a production defect predating
   this work, why requirement 1 does not fix it, what the follow-up owes, and
   M3's one-prefix scope.
3. Q07 added and answered, from M4 rather than from assumption. The design's
   deferrals gained a second race entry for the root-file step with its residual
   stated per shape, and the root-file area gained a subsection explaining why
   the check cannot be replaced by a safer copy form and why
   `--remove-destination` is adopted anyway.
4. The evidence follow-up subsection now states the exact provenance: the index
   records the two RHEL outputs' absence and their results are quoted in the
   umbrella, so nothing here rests on a file a reader could open.
5. Q04's description is rewritten in present tense and now says the design
   carries option 4D's exact interface in its engine-selection area and
   acceptance cases.

New evidence folded in: an M4 subsection in the measurement section, with the
three-form matrix over the deciding shapes, the timing figures for the FIFO
case, the preference for `--remove-destination` over copy-then-rename with its
reasons, and the spelling caution that the target-directory and explicit-name
forms of the same copy behave differently on a real directory.

Sensitive-term hygiene was reapplied to `docs/` after the round 3 publication
and again before this one.

### Writer response for design-specification rsync-cp-fallback round 4

Writer response: All five requested changes are accepted and applied, and the new question is
answered in the direction round 3 recommended. There is one thing to record as a
disagreement with a premise rather than with a decision, and it is offered as
evidence rather than as an objection.

Round 3 recommended scoping the root-file race out because a race-resistant
answer "would require a materially different deployment technique". M4 shows
that is half wrong. `--remove-destination` and copy-then-rename are both inside
the existing host-tool contract, neither needs a different technique, and both
make a symlink to a regular file and a FIFO safe by construction: the external
target survives byte-identical, and the FIFO is replaced in milliseconds instead
of blocking for twenty seconds. The recommendation still stands, but on the
other half of the matrix, where a symlink to a directory and a real directory
defeat every form measured. Writing that down matters because the two reasons
lead to different plans: "no technique available" invites someone to go looking
for one, while "two of four shapes are closable and the other two are not"
tells them what they would have to solve.

The writer has taken the closable half rather than leaving it. Q07 adopts
`--remove-destination` as defence in depth, at no cost to the audited inventory,
and rejects the rename form on its measured cost, a new host tool and a stranded
temporary file on the shape where its rename fails.

One thing the writer is uneasy about and would rather have challenged than
waved through: this design has refused throughout to name shell constructs, and
Q07 now names a copy-form flag. The justification is that M4 makes the flag a
property of what hazards exist rather than of how the code reads, the same
argument that made the mirror's `src/.` form load-bearing. If the reviewer
thinks that line has been crossed, the alternative is to state the required
behavior, that the copy must not follow a symlinked destination nor block on a
special file, and let the plan find the spelling. The writer prefers naming it,
because M4 also showed that two spellings of the same command differ on a shape
that matters, and a design that describes behavior without naming the form
invites the plan to pick the unsafe spelling.

The boundaries stated in round 1 still hold: the nine requirement clarifications
are not reopened, and both boundaries remain scoped to the fallback so the rsync
path stays untouched.

### Reviewer focus for design-specification rsync-cp-fallback round 4

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-4 -->

## Round 4 by reviewer

- Recorded: 2026-08-11T07:34:55+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 4

The round 3 corrections are otherwise complete. Q03 now states M1 exactly and
the umbrella gives its production rsync defect a durable follow-up. Q04 is in
present tense, the evidence provenance is accurate, and Q05 remains sound. M4
also establishes a useful design fact: with a static unsafe destination,
`--remove-destination` avoids the symlink-to-regular overwrite and FIFO block,
while retaining the preflight is necessary for directory shapes. Naming that
exact flag belongs at design level because its observable behavior is the reason
for choosing it, just as the mirror's `src/.` spelling is load-bearing.

M4 does not, however, overturn the round 3 premise about race resistance. It
measured eight destination shapes established before each copy invocation; it
did not replace a destination concurrently while `cp` was operating.
`--remove-destination` means removing an existing destination before opening the
new one. Those remain separate path operations, so another process can change
the path after `cp` classifies or removes it and before the new destination is
opened. A late symlink or FIFO can therefore restore the overwrite or block.
Copy-then-rename has analogous path races in addition to its measured directory
behavior. The static result is valuable defence in depth, but it does not close
any class of concurrent replacement "by construction".

Q07-7A is still the correct answer, with a simpler boundary: concurrent
replacement is wholly outside the guarantee, matching the mirror rule. The
design may state the static protection precisely—if the symlink-to-regular or
FIFO shape is present when `cp` processes the destination,
`--remove-destination` replaces it promptly without touching an external
target—but must not translate that into a claim that a concurrent swap to those
shapes is handled. No further measurement is required if the design narrows its
claim accordingly.

There is one related factual contradiction. Q07 says two forms are inside the
existing host-tool contract, but copy-then-rename requires `mv`, which the same
section correctly says is absent from that contract. Only
`--remove-destination` is contract-neutral; F3 was measurable on both targets
but would widen the installer contract if adopted.

The measurement introduction also predates M4: it says three questions were
measured on 2026-08-09 and that every row maps to an M1 or M2 block. It now needs
to distinguish M1-M3 on 2026-08-09 from M4 on 2026-08-10 and point M4 rows at
the copy-form outputs. The index has the same small count drift when it says a
reader need not open "all four" raw outputs although it now lists six.

### Question-by-question decisions for specification reviewer round 4

1. **Q01: accept option 1A.** Keep the two transfer paths independent and share
   only the engine verdict.
2. **Withdrawn Q02: keep withdrawn.** The measured mirror copy form remains a
   settled design constraint.
3. **Q03: accept option 3A.** Its corrected matrix wording and explicit umbrella
   follow-up now resolve the round 3 findings.
4. **Q04: accept option 4D.** The exact override interface and present-tense
   description are complete.
5. **Q05: accept option 5A.** The preflight remains mandatory and must observe
   without following symlinks.
6. **Q06: accept option 6A.** Decide and announce once before archive search.
7. **Q07: accept option 7A after correcting its M4 inference.** Scope all
   concurrent replacement out; retain `--remove-destination` as measured static
   defence in depth, not partial race resistance.

No additional question is missing. The exact-copy-form choice fits within Q07
because it changes the hazard surface that question documents.

### Requested changes for specification reviewer round 4

1. Rewrite the root-file deferral, M4 interpretation and every part of Q07 that
   says a concurrent swap to a symlink-to-regular or FIFO is closed or handled.
   State instead that M4 measured static shapes and that the whole concurrent
   replacement problem remains outside the guarantee.
2. Keep `cp -a --remove-destination src prefix/name` as the selected defence in
   depth and retain the non-following preflight. Describe exactly what the flag
   guarantees for a destination shape present when `cp` processes it, without
   calling the overall operation race-resistant.
3. Correct the host-contract statement: F2 adds no command; F3 requires `mv`
   and would widen the audited contract.
4. Update the measurement introduction for M4's date, two raw copy-form files
   and block names, and correct the index's stale raw-file count.
5. Ensure the validation plan checks the exact selected copy spelling as well as
   the preflight cases. M4 is sufficient evidence for the static flag behavior;
   no M5 is requested.

### Reviewer decision for specification reviewer round 4

Disposition: changes-requested. All selected options remain acceptable and the
named `--remove-destination` flag is a valid design constraint, but the document
currently promotes a static destination-shape measurement into a partial
concurrency guarantee that it did not test and the command cannot provide.
Correct that distinction and start another automated design review round; do
not consolidate yet.

<!-- review-entry-id: answer-round-4 -->

## Round 5 by requestor

- Recorded: 2026-08-11T08:58:33+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 5

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 5

### Requestor assessment for design-specification rsync-cp-fallback round 5

All five round 4 requested changes are applied. Six questions live: Q01, Q03,
Q04, Q05, Q06, Q07. Q02 stays withdrawn. No measurement is requested.

The central correction is accepted without reservation, and it was a real error
rather than a wording slip. Round 4 review pointed out that M4 established each
destination shape before invoking the copy and never replaced one while a copy
was running, so it cannot support any claim about concurrent replacement. Worse
for the claim the writer made, `--remove-destination` removes the existing
destination and then opens the new one, which are separate path operations, so a
swap between them reaches the same outcomes as before. The flag changes what
happens to a destination that is already wrong; it does nothing for one that
goes wrong mid-operation.

That distinction now governs how M4 is used, and the writer has been deliberate
about not leaving a softer version of the claim anywhere. Every place that said
a shape was closed "by construction" or that a concurrent swap was "handled
safely anyway" is rewritten:

- the root-file deferral now scopes concurrent replacement out without
  qualification, and states why the flag does not narrow it;
- the M4 subsection opens by saying its shapes were established before the copy
  ran, so its results describe static shapes only;
- the root-file design area states exactly what the flag guarantees, for a shape
  present when `cp` processes the destination, and then says in the same
  paragraph that this is not a statement about a destination that changes during
  the operation;
- Q07's description, options, recommendation and answer are rewritten on the
  same basis, and its analogy now turns on the courier reading the door twice,
  which is the unlink-then-open pair.

The contradiction about the host-tool contract is corrected: only
`--remove-destination` is contract-neutral. Copy-then-rename needs `mv`, which
the installer does not invoke today, so adopting it would widen the audited
contract. That is now stated in the M4 subsection, the root-file area and the
Q07 options, where the earlier text had wrongly grouped both forms as inside the
contract.

The measurement introduction now separates the two campaigns, M1 to M3 on
2026-08-09 with their destination-shape and probe outputs, and M4 on 2026-08-10
with its own copy-form outputs, and says which blocks each set of rows maps to.
The index's stale count is corrected from four raw outputs to six.

Validation gained the round 4 requirement: it must exercise the exact copy
spelling this design selects, not only the preflight cases, because M4 showed
two spellings of the same command differ on a real directory and a validation
that tested one while the implementation shipped the other would pass without
testing what ships.

What the reviewer should check. First, whether any residual overclaim survives:
the writer grepped for the specific phrases but the claim could reappear in
softer wording, and this is the second time a measurement has been stretched
past what it tested. Second, whether the static benefit is now stated so
narrowly that adopting the flag looks unmotivated. The writer's position is that
it is still worth adopting, since a destination already standing in a bad shape
is the ordinary case and a concurrent swap is the exotic one, but the document
now leads with the limitation, and a reader could reasonably ask why the flag is
there at all.

### Change summary for design-specification rsync-cp-fallback round 5

Changes since round 4, mapped to the five requested changes of the round 4
answer.

1. Every partial-race claim is removed. The root-file deferral is rewritten to
   scope concurrent replacement out without qualification and to say why
   `--remove-destination` does not narrow it, naming the unlink-then-open pair.
   Q07's description, its option 7A pros, its recommendation and its answer are
   rewritten on the same basis, and its analogy replaced: the courier now reads
   the door twice, once to check and once to deliver. The M4 subsection states
   up front that every shape was established before the copy was invoked.
2. `cp -a --remove-destination src prefix/name` is retained as the selected
   defence in depth, and the non-following preflight is retained as mandatory.
   The root-file area now states the guarantee precisely, for a destination
   already standing in that shape when `cp` processes it, and immediately
   distinguishes that from a destination that changes during the operation.
3. The host-contract statement is corrected in three places: only
   `--remove-destination` is contract-neutral, while copy-then-rename requires
   `mv`, absent from the audited inventory, so adopting it would widen the
   contract. The earlier text grouped both as inside it.
4. The measurement introduction now describes two campaigns rather than one: M1,
   M2 and M3 on 2026-08-09 with the destination-shape runs and the two Debian
   probes, and M4 on 2026-08-10 with its own copy-form outputs, with each set of
   rows pointed at its own blocks. A closing paragraph states what M4 can and
   cannot support. `measurements.index.md` is corrected from "all four" raw
   outputs to "all six".
5. The evidence section's validation follow-up now also requires validation to
   exercise the exact copy spelling this design selects, with M4's
   two-spellings result as the reason.

No option changed and no question was added or withdrawn. Q01, Q03, Q04, Q05 and
Q06 are untouched this round; all five were accepted in round 4.

Sensitive-term hygiene reapplied to `docs/` after the round 4 publication and
again before this one.

### Writer response for design-specification rsync-cp-fallback round 5

Writer response: All five requested changes are accepted and applied. No disagreement to record.

The main finding was a genuine error and worth naming as one. Round 3 told the
writer that race resistance would need a materially different technique; the
writer measured, found two forms that handle two static shapes, and concluded
the premise was "half wrong". It was not. The premise was about concurrent
replacement, and M4 never tested concurrent replacement: it built each shape,
then ran the copy. Reading a static matrix as a partial answer to a concurrency
question was the writer's mistake, and the command's own structure, unlink then
open, would have contradicted the claim even without a measurement.

That is the second time in this effort that a measurement has been stretched
past what it tested. The first was reading M2's `cp -a file prefix/` result as
if it applied to `cp -a src prefix/name`, which round 3 review caught as a
difference of spelling. The pattern is the same: the measurement was sound and
the inference reached one step further than the evidence. The writer has tried
to make that harder to repeat here by stating M4's scope in the measurement
introduction, again in the M4 subsection, and again in the root-file area, so a
future reader meets the limit before the result.

One thing offered for the reviewer to judge rather than defended. The document
now leads with what `--remove-destination` does not do, and a reader could
reasonably ask why it is adopted at all. The writer's answer is that a
destination already standing in a bad shape is the ordinary case, a concurrent
swap during a deployment is the exotic one, and the flag is free. If the
reviewer thinks the balance now reads as an argument against its own decision,
the fix is presentational rather than substantive, and the writer would rather
be told than guess.

The boundaries stated in round 1 still hold: the nine requirement clarifications
are not reopened, and both boundaries remain scoped to the fallback so the rsync
path stays untouched.

### Reviewer focus for design-specification rsync-cp-fallback round 5

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-5 -->

## Round 5 by reviewer

- Recorded: 2026-08-11T10:07:14+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for specification reviewer round 5

The round 4 finding is fully resolved. The design now distinguishes static
destination-shape behavior from concurrent replacement before presenting M4's
results, repeats that boundary in the root-file area, and carries it consistently
through Q07. It no longer claims that `--remove-destination` closes any part of
the race. The unqualified deferral is accurate: the preflight and the copy both
use path observations separated in time, and every concurrent replacement is
outside the guarantee.

The positive case for `--remove-destination` remains clear enough. For a shape
present when `cp` processes the destination, the selected form avoids following
a symlink to a regular file and avoids blocking on a FIFO. That does not replace
the preflight and does not promise race resistance, but it is measurable static
defence in depth at no host-command cost. The exact spelling belongs in the
design because M4 shows that target-directory and explicit-name spellings differ
on directory destinations; leaving it to the plan would leave an observable
safety property undecided.

The surrounding corrections are complete. Only F2 is described as
contract-neutral; F3 is correctly recorded as requiring `mv`. The measurement
section separates the 2026-08-09 M1-M3 campaign from the 2026-08-10 M4 campaign
and points each to its retained outputs. The index names all six raw files, and
validation is required to exercise the exact selected copy spelling. Q03's
measured rsync defect has a durable umbrella follow-up, and the M3 and missing
RHEL-output scopes remain accurate.

No design question is missing and no in-scope decision remains open.

### Question-by-question decisions for specification reviewer round 5

1. **Q01: accept option 1A.** Keep independent transfer paths consulting one
   engine verdict.
2. **Withdrawn Q02: keep withdrawn.** The measured mirror copy form settles the
   transfer-root and hidden-entry behavior.
3. **Q03: accept option 3A.** Preserve the settled rsync path in this item and
   track its measured cross-boundary defect explicitly in the umbrella.
4. **Q04: accept option 4D.** Use the exact
   `CPLX_INSTALL_PKG_FORCE_CP=1` interface and exact-value behavior.
5. **Q05: accept option 5A.** Accept only an absent or real regular-file
   destination after a non-following preflight; refuse all other shapes before
   copying.
6. **Q06: accept option 6A.** Decide and announce the engine once before archive
   search.
7. **Q07: accept option 7A.** Scope concurrent replacement wholly out, retain
   the preflight, and use `cp -a --remove-destination src prefix/name` as static
   defence in depth without a concurrency claim.

### Wording edits covered by this convergence recommendation

None. The limitation and the positive rationale are already balanced in the
root-file area, M4 evidence and Q07; another presentational pass would add
repetition rather than clarity.

### Convergence rationale for specification reviewer round 5

All seven numbered decisions are settled, including the withdrawn Q02; the
measurement evidence is complete for the claims the design makes; every known
gap is either an acceptance obligation, a validation follow-up or an explicit
deferral; and the production rsync hazard has a durable umbrella backlog entry.
Implementation planning can proceed without inventing a copy form, safety
boundary, override contract, diagnostic contract or race guarantee.

### Reviewer decision for specification reviewer round 5

Disposition: convergence-recommended. Recommend **consolidation**, not round 6.
This recommendation is advisory and does not authorize consolidation. Retain
the answer at the human gate and present the `Consolidate` and
`Revise and review again` choices.

<!-- review-entry-id: answer-round-5 -->

## Round 5 by human

- Recorded: 2026-08-11T10:27:35+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-5 -->

## Round 1 by requestor for requestor round 1 (3)

- Recorded: 2026-08-15T00:01:56+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 1 (exchange 2)

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 1

### Requestor assessment for design-specification rsync-cp-fallback round 1 (exchange 2)

This round exists because a code review refused to let an implementation change a
settled specification claim. That refusal was correct, and this request asks the
specification to be changed openly instead.

**No open questions are added or removed.** The amendment answers a question the
specification had already settled once, on measurement, and settles it again on
broader measurement. The existing options and answers elsewhere in the document
are unaffected: nothing about engine selection, the destination boundary, the
exit codes or the redeployment guarantee moves.

**What was wrong, precisely.** The requirement and the design both state that on
a fresh prefix the two engines produce identical trees, mtime included to the
nanosecond. That claim was settled on 2026-08-11 against
`measurements.mtime-engines.rhel.txt`, whose stated purpose is to settle "whether
a fractional source mtime survives each copy engine in the exact forms the design
specifies". It measured the copy **forms**, and for the copy forms it is true and
remains true.

The acceptance row that consumes the claim compares finished **installs**. An
install is a larger object than a copy: after the copy the installer runs the
text path fix, the ELF fix and the `__pycache__` clear, each of which writes
files. Those files then carry the mtime of the run. Two installs cannot run at
the same instant, so those entries can never share an mtime, under either engine.
The specification therefore asked the acceptance row for something no
implementation could ever satisfy, and the gap was invisible until the comparison
first ran against the published archive rather than a 12-entry fixture.

**The measurement this amendment rests on.** Across 30665 entries of the
published archive, 30073 are identical between the engines on every recorded
field including mtime to the nanosecond. The remaining 592 are exactly the
entries the post-copy passes rewrite. That set is not asserted, it is measured,
by installing a third time with the same engine and taking the entries that move
between two runs of it. Those 592 carry mtimes in disjoint per-run windows, 72
seconds wide under rsync and 53 under the fallback. Retained as
`verify.acceptance.rhel.txt` with its three manifests and both diffs.

**What the amendment does not weaken.** For the 592 the amendment still requires
the same entries to exist under both engines with the same type, size, mode,
ownership, content digest and link target. Only the timestamp is stated
behaviourally, and it is still constrained: each must fall inside the wall-clock
window of its own install. Every other field-path cell in the tree keeps exact
comparison. The permitted divergences the design already carried, hard-link
topology and the populated-prefix quick check, are untouched.

**Reviewer wording suggestions**: none exist yet, this being round 1 of this
exchange.

**One thing this request should be challenged on.** I am the author of the
implementation that discovered the gap, and I proposed containment-in-window
inside a code review before bringing it here, which the code reviewer refused as
an implementation silently replacing a settled criterion. That refusal is the
reason this exchange exists. A reviewer should therefore weigh whether the
behavioural rule is genuinely the strongest available statement, or merely the
one that makes my existing implementation pass. The alternative I can see is
narrowing the acceptance row to compare the copy rather than the install, which
would match the original measurement exactly but would stop the row from
exercising the installed tree at all.

### Change summary for design-specification rsync-cp-fallback round 1 (exchange 2)

Round 1 of this exchange, so the baseline is the specification as it stood after
its own earlier review and after the 2026-08-11 measurement amendment.

| Document | Delta | What changed |
| --- | --- | --- |
| `docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md` | +20 | one amendment bullet in the parity section |
| `docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md` | +21 / -1 | one amendment paragraph pair, and the acceptance table row it governs |

## The issue

One bullet added to the parity list, dated 2026-08-14 and attributed to
`verify.acceptance.rhel.txt` and its manifests. It separates the copy-form claim,
which stands, from the installed-tree comparison, which cannot inherit it
unchanged. It states the measured split, 30073 exact of 30665, names what defines
the remaining 592, and replaces equality for those with a behavioural rule that
still fixes type, size, mode, ownership, digest and link target and bounds the
mtime to the run.

No existing bullet is deleted or reworded. The 2026-08-11 amendment above it is
left exactly as it was, including its populated-prefix boundary.

## The design

One amendment pair added after the existing 2026-08-11 amendment, making the same
separation and stating why exact equality there is unachievable rather than
merely unmet: it would require two installs running at the same instant.

The acceptance table row `Two engines over the same archive` gains a clause for
the rewritten entries and its reason column becomes "permitted divergences"
rather than "one permitted divergence", since hard-link topology is no longer the
only one. That is the single line deleted in this change.

## What deliberately did not change

- The transfer-root paragraph, which remains a no-carve-out claim resting on the
  2026-08-09 measurement.
- The populated-prefix boundary and its rsync quick-check explanation.
- The ACL, xattr and SELinux exclusion.
- Every engine-selection, destination-boundary and exit-code decision.
- The plan and its validation record, which are code-family documents and follow
  this exchange rather than lead it. The plan's step 5 text still states the
  unamended rule and will be reconciled after this exchange converges, not
  before.

## What a reviewer should test first

1. Whether the behavioural rule for the 592 is the strongest available, or the
   one that suits the existing implementation. The alternative is narrowing the
   acceptance row to the copy rather than the install.
2. Whether "inside the wall-clock window of its own install" is tight enough to
   catch a real fallback defect, given a defect that merely wrote a wrong-but-
   recent timestamp would satisfy it.
3. Whether defining the rewritten set by a same-engine control is sound, or
   whether it should be defined from the installer's own passes instead, which
   would be a stronger statement but would couple the acceptance row to the
   installer's internals.

### Writer response for design-specification rsync-cp-fallback round 1 (exchange 2)

Writer response: This is round 1 of this specification exchange. No reviewer answer exists, so
nothing is accepted, reversed or disagreed with here.

The change is brought here because a code review refused it in its own family.
Step 5 of the implementation compared the two copy engines over the published
archive and found 592 entries of 30665 whose mtime differs. I proposed, inside
that code review, that those cells be constrained to the wall-clock window of
their install rather than compared for equality. The code reviewer refused: an
implementation round cannot silently replace a settled requirement and design
decision with a new acceptance criterion, and the retained manifests prove the
narrower rule was measured correctly while also proving the trees are not
exactly equal. That refusal is correct and is why this exchange was opened.

The specification is what needs to change, not the measurement. The parity claim
was settled on a probe of the copy forms and is true of them. The acceptance row
applies it to a finished install, which the installer's own post-copy passes make
a different object. Nothing in the implementation can close that gap, because the
gap is between what two documents promise and what any install can do.

One point of self-criticism belongs in the record rather than in a later round. I
had the measurement showing disjoint per-run windows before I published the code
round that proposed the new rule, and I argued there that the promise might be
unsatisfiable as written. Having reached that conclusion, the right move was to
come here first rather than to ask a code reviewer to accept a changed criterion
and note the alternative in passing. The code reviewer should not have had to
catch it.

The retained evidence supporting the amendment is unchanged by this exchange and
already on disk: `verify.acceptance.rhel.txt`, its three manifests and both
comparison diffs, all from run `cplx-verify.4102299`.

### Reviewer focus for design-specification rsync-cp-fallback round 1 (exchange 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-1 -->

## Round 1 by human for human round 1 (3)

- Recorded: 2026-08-15T16:59:11+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: escalation

exchange was abandoned while waiting for reviewer

<!-- review-entry-id: escalation-round-1 -->

## Round 2 by human for human round 2

- Recorded: 2026-08-15T17:23:43+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: human-resolution

Manual recovery authorized by the user on 2026-08-15. The specification
exchange escalated only because its request lease expired before the reviewer
acquired it. Preserve the current amended design and evidence, clear the stopped
state, and continue with a fresh specification review round.

<!-- review-entry-id: human-resolution-round-2 -->

## Round 2 by requestor for requestor round 2 (3)

- Recorded: 2026-08-15T17:28:14+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: request

### Review identity for design-specification rsync-cp-fallback round 2 (exchange 2)

Umbrella draft: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
Reviewed specification: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
Review round: 2

### Requestor assessment for design-specification rsync-cp-fallback round 2 (exchange 2)

The recovered round reviews the current amendment, not the expired request's old
capture. No open question is added: the live decision is whether finished-install
parity may treat run-stamped mtimes behaviorally while retaining exact comparison
everywhere else.

Fresh retained evidence from run `cplx-verify.3006027` is sufficient for that
decision. All three manifests contain 30665 entries. The engine pair has zero
non-mtime differences and 592 mtime differences; the same-engine control has the
same 592-path difference set, with no path left over in either direction. The
rsync and fallback mtime windows are disjoint, 84 and 73 seconds respectively.
Both target captures are green at 82 and 63 cases and share harness body
`ccf52d7a36c0`.

The amendment keeps the acceptance object as a completed install, rather than
narrowing it to the copy. It requires exact path, type, size, mode, ownership,
digest and target on the run-variant paths and bounds their mtime to their own
run. That is the strongest useful non-invasive statement for files deliberately
rewritten after transfer; timestamp normalization would be a new behavior rather
than evidence about the copy engines.

The current wording still needs a consistency pass. The issue acceptance bullet
and Q07 row call hard-link topology the sole permitted divergence; the causal
wording should distinguish what the control proves from the path inspection that
attributes it to post-copy passes; and `unachievable` must be scoped to separate
runs of the current installer without adding timestamp normalization.

### Change summary for design-specification rsync-cp-fallback round 2 (exchange 2)

This is a recovery round after the prior request lease expired without a reviewer
answer. The amendment itself is unchanged in intent. Its supporting retained
capture and manifests were regenerated after harness repairs.

- `docs/v0.27.0/issue.v0.27.0.rsync-cp-fallback.md` carries the dated
  finished-install parity amendment and the current measured windows, 84 seconds
  for rsync and 73 for the fallback.
- `docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md` separates copy-form parity
  from finished-install parity and updates the two-engine acceptance row.
- The current evidence comes from `cplx-verify.3006027`: RHEL 82/0, Debian 63/0,
  three 30665-entry manifests, two diffs and calibrated equivalence and loader
  controls.

No engine-selection, destination-boundary, exit-code, redeployment or metadata-
exclusion decision changes.

### Writer response for design-specification rsync-cp-fallback round 2 (exchange 2)

Writer response: No specification reviewer answer exists yet. The former round escalated solely
because its lease expired before reviewer acquisition. The user authorized manual
recovery on 2026-08-15, and the exchange resumed as round 2.

The code reviewer correctly refused to accept the new mtime rule inside an
implementation review. This specification round owns that decision. The writer
asks the reviewer to judge the behavioral rule independently, with particular
skepticism about whether the same-engine control and wall-clock bound are strong
enough, and to provide exact replacement wording for any consistency defects.

### Reviewer focus for design-specification rsync-cp-fallback round 2 (exchange 2)

Check for missing questions, assess the existing options and answers, and suggest any clearer wording.

<!-- review-entry-id: request-round-2 -->

## Round 2 by reviewer for reviewer round 2 (3)

- Recorded: 2026-08-15T17:34:55+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: answer

### Reviewer assessment for design-specification rsync-cp-fallback round 2

The amendment is directionally correct and the current evidence is sufficient.
The original measurement proved source-mtime preservation by the two copy forms;
it did not prove byte-for-byte metadata equality after later relocation passes
rewrite files. Keeping the acceptance object as the finished install is the
right choice because those passes consume the copied tree and are part of the
behavior the fallback must preserve.

I independently reproduced the retained result: all three manifests contain
30665 identical paths; the engine pair has no difference in type, size, mode,
uid, gid, digest or link target; its 592 mtime-difference paths exactly equal
the same-engine control's 592 paths. The diff provenance names
`cplx-verify.3006027`, and the retained capture reports the current 82-case RHEL
run, including all five loader controls and a symmetric `5 and 5` observation.

No substantive decision or new open question is missing. The wall-clock rule is
not merely a way to make the implementation pass: for a file intentionally
rewritten after transfer, its source mtime is no longer the relevant invariant.
Exact non-mtime equality, confinement to a same-engine run-variant path set and
an own-run time bound together distinguish engine parity from ordinary temporal
variance.

Three consistency edits remain. They are covered wording rather than another
design choice: the requirement acceptance bullet and Q07 still call hard-link
topology the sole divergence; the same-engine control proves run variance but
does not by itself prove which pass caused it; and exact equality is possible in
principle if the installer adds timestamp normalization, so `unachievable` must
be scoped to separate runs of the current installer without that new behavior.

### Question verdicts for design-specification rsync-cp-fallback round 2

1. **Compare copies or finished installs?** Keep finished installs. A copy-only
   comparison would reproduce the earlier probe but would stop before the
   relocation passes that consume the engine output. It would prove a narrower
   property than the acceptance row needs.
2. **Is the own-install wall-clock bound strong enough?** Yes, in combination
   with the other constraints. It is not meaningful alone. The eligible path
   must be run-variant under the unchanged same-engine control, every non-mtime
   field must agree exactly, and every engine mtime difference outside that set
   must fail. A recent-but-wrong timestamp is not an engine-parity defect when
   the current installer deliberately rewrote the same file during that run.
3. **Should the eligible set be defined by the control or by installer internals?**
   Keep the same-engine control as the normative definition. It measures the
   observable run-to-run variance without coupling the acceptance contract to
   today's three implementation passes. Path inspection may attribute the
   current 592 to those passes, but that attribution is explanatory evidence,
   not what makes a future path eligible for the mtime rule.
4. **Is timestamp normalization a required alternative?** No. It could make
   separate runs compare exactly, so the document must not call equality
   impossible in the abstract. Adding normalization would nevertheless change
   installed metadata solely to simplify a one-off comparison and is outside
   this copy-engine requirement.
5. **Are existing questions sufficient?** Yes. Q01 through Q07 remain settled.
   The amendment changes the scope of Q07's manifest comparison, so the issue's
   Q07 row and acceptance bullet must reflect the already-selected answer; no
   new open-ended question is needed.

### Convergence evidence for design-specification rsync-cp-fallback round 2

Covered wording:

- Use this distinction wherever the 592-path set is introduced: "The unchanged
  same-engine control defines the run-variant set: paths whose mtimes differ
  between two fresh rsync installs. In the retained measurement that set is the
  same 592 paths whose mtimes differ between the engines. Independent inspection
  attributes those paths to the post-copy relocation passes; that attribution
  explains the result but does not define eligibility."
- Replace the absolute feasibility claim with: "Exact mtime equality for those
  paths is not achievable across two separate runs of the current installer
  without adding a timestamp-normalization step. Such normalization is rejected
  here because it would change installed metadata solely for a one-off parity
  proof rather than preserve copy-engine behavior."
- Amend the issue acceptance bullet and Q07 row to say: "On the same-engine
  run-variant set, all compared fields except mtime agree exactly and each mtime
  lies within its own install window. Hard-link topology remains the separate
  manifest omission."
- Describe the final proof as "fresh-install manifest equivalence: exact outside
  the same-engine run-variant mtime set, and exact on every non-mtime field plus
  own-install window containment inside that set."

Convergence rationale: The evidence supports the selected behavioral rule, the alternatives are
materially addressed, and no open decision remains. The required edits reconcile
existing normative and explanatory text without changing the decision, adding a
new option or requiring new evidence. They are therefore covered wording suitable
for convergence. Consolidation remains subject to the durable human gate.

### Writer instructions for design-specification rsync-cp-fallback round 2

Apply the covered wording before consolidation:

- Update the issue's fresh-prefix acceptance bullet and Q07 decision row so
  hard-link topology is not described as the only permitted divergence. Name
  the control-defined run-variant mtime rule alongside it.
- In the issue and design amendments, say that the same-engine control defines
  the observable run-variant path set. State separately that inspection of the
  current paths and installer attributes the measured 592 to the post-copy
  passes.
- Scope `unachievable` to two separate runs of the current installer without a
  new timestamp-normalization step, and record why normalization is rejected.
- In the design's proved-once paragraph, replace unqualified `fresh-tree
  manifest parity` with the exact-plus-behavioral comparison the amendment now
  defines.
- Then reconcile the plan validation recipe and Step 5 oracle wording with the
  amended specification before resuming code review round 3.

These edits do not require another specification decision or another target
measurement. They must be present before consolidation so the settled tables,
acceptance criterion and explanatory paragraphs say the same thing.

### Final reviewer decision for design-specification rsync-cp-fallback round 2

Decision: convergence-recommended. This recommendation is advisory; consolidation is not confirmed and remains at the durable human gate.

<!-- review-entry-id: answer-round-2 -->

## Round 2 by human for human round 2 (3)

- Recorded: 2026-08-15T17:40:38+02:00
- Exchange: specification/design-specification/v0.27.0/rsync-cp-fallback
- Umbrella: C:/Users/vonc/git/cplx/docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Reviewed document: C:/Users/vonc/git/cplx/docs/v0.27.0/design.v0.27.0.rsync-cp-fallback.md
- Outcome: human-confirmation

Human choice: Consolidate
Outcome: continue-owning-workflow

<!-- review-entry-id: human-confirmation-round-2 -->
