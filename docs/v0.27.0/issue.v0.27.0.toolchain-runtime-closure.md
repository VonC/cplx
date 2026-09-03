# Ship a complete runtime closure in the archive

Reference draft: [draft.v0.27.0.toolchain-runtime-closure.md](draft.v0.27.0.toolchain-runtime-closure.md)
Reference umbrella: [draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md), item 4
Reference environments: [reference.environments.md](reference.environments.md)

## Revision history for the toolchain runtime closure

- EARLIER READING, develop#19: listing `root/usr/lib64` alone, the probe
  concluded `libgcc_s.so.1` was missing from the archive and that packaging had
  dropped it between RPM extraction and `pkg.sh`.
- CORRECTED READING, develop#24: listing all eight directories
  `build_elf_rpath` puts on the rpath, `libgcc_s` ships as
  `root/lib64/libgcc_s-11-20240719.so.1` under the python root and the git root
  alike. The four glibc compat stubs and `libstdc++.so.6.0.29` are in
  `root/usr/lib64`. There is no drop to repair.

THE CORRECTION IS THE REASON THIS ISSUE EXISTS IN ITS PRESENT FORM. What the
archive owes is not a missing library but a GUARANTEE that a future packaging
run cannot ship an incomplete or incoherent root silently.

## Current behavior in v0.27.0

1. `pkg.sh` packages the toolchain from the build-account tree with no
   enumeration of the runtime members the archive must carry.
2. `install_pkg.sh` extracts that archive and relocates it: `build_elf_rpath`
   composes ONE ordered search list across EVERY tool root, python first, from
   each root's `root/usr/lib64`, `root/usr/lib`, `root/lib64`, `root/lib` and
   each version directory's `lib` and `lib64`, and the relocation pass writes
   that single value into every ELF it patches.
3. Whatever the loader cannot resolve from that shipped root, it takes from the
   host `ld.so.cache`.
4. Nothing at packaging time compares the shipped set against the set the
   runtime demands, and nothing checks that the shipped libraries agree with
   each other.

## Current side effects in v0.27.0 for the runtime closure

- A MISSING MEMBER SHIPS SILENTLY AND FAILS ONLY ON DEBIAN. `libsqlite3.so.0`
  is absent from the whole root, confirmed on 2026-08-08 by searching the live
  tree on the build account, while the RHEL 9.8 servers carry their own copy in
  `/usr/lib64`. An archive built without it therefore passes on RHEL and fails
  on the agent.
- AN INCOHERENT SNAPSHOT SHIPS SILENTLY. The published 9.13.4 libc lacks the
  `GLIBC_2.35` version node that the current RHEL `libgcc_s` demands, while the
  live build-account root has it: the archive had diverged from the tree it was
  packaged from.
- SUPERSEDED GENERATIONS AND DUPLICATED FAMILIES ACCUMULATE. The 9.13.4 root
  carries two libbfd builds side by side, and develop#24 finds the OpenSSL pair
  duplicated, one copy per tree, python and git.
- On Debian the resulting resolution mixes glibc 2.36 objects into a RHEL 2.34
  process and dies with `GLIBC_ABI_DT_RELR` or `GLIBC_2.36 not found`. RHEL
  targets never see any of it: their cache serves compatible copies.

## Gap analysis for the runtime closure

The umbrella's rule is that the shipped root must be ONE SNAPSHOT that resolves
inside itself on any supported distribution. The current packaging asserts no
part of that.

| What the rule requires | What packaging does today |
| --- | --- |
| every member the archive is meant to carry is present | no declared member list exists; presence is whatever the build tree happened to hold |
| every dependency a shipped object records resolves inside the archive | never checked |
| every version need is satisfied by the shipped object selected for that dependency | never checked; the 9.13.4 archive shipped with the `GLIBC_2.35` gap |
| one object per SONAME, and one generation per declared family, in the one scope | never checked; two libbfd generations ship together |
| a gap is caught where it is created | a gap is caught on the Debian agent, one delivery later, if at all |

THE ASYMMETRY IS THE WHOLE DIFFICULTY. A closure gap is invisible on the
distribution the archive is built on and fatal on the distribution CI runs, so
a check performed on the build account proves nothing. That asymmetry is what
kept this family invisible until CI ran on Debian.

## The provider-aware coherence rule

THE EARLIER WORDING OF THIS RULE WAS TECHNICALLY FALSE, and it is corrected here
rather than quietly reworded. This issue first said "every version node demanded
by a shipped library is defined by the shipped libc", which is the umbrella's
own phrasing. It holds only for `GLIBC_` needs. `GLIBCXX_` and `CXXABI_` nodes
are defined by libstdc++, and `OPENSSL_` nodes by libcrypto. A libc-only check
would reject a coherent OpenSSL or C++ pair, or ignore its real provider.

THE INVARIANT IS PROVIDER-AWARE. For every shipped object, and for every version
need it records:

1. the need is recorded against a named provider, its `DT_VERNEED` file entry;
2. that provider is resolved to the shipped object the archive's own search
   scope selects for the corresponding `DT_NEEDED` entry;
3. that selected object defines the needed node;
4. the resolution stays INSIDE the archive: no step of it falls back to the
   host.

`libc.so.6` is therefore the provider for `GLIBC_` needs and for those only, and
the same rule reads OpenSSL and C++ pairs without a special case.

CONDITION 4 IS THE ONE THE BUILD HOST CANNOT ANSWER. On RHEL the host cache
serves a compatible object for any step that falls out of the archive, so the
first three conditions can all hold while the fourth silently does not.

## Confirmed rules for the runtime closure

- TWO INDEPENDENT MEMBERSHIP HALVES, neither passing for the other:
  - the DERIVED closure, every `DT_NEEDED` of every shipped object resolves
    inside the archive search scope;
  - the DECLARED FLOOR, an explicit committed list of members the archive must
    carry regardless of whether anything currently declares them.
  A derived check alone cannot see a member dropped from both the payload and
  its consumers, which is the `libsqlite3.so.0` shape exactly.
- THE PROVIDER-AWARE COHERENCE RULE above, in place of the libc-only one.
- DUPLICATE PROVIDERS AND CROSS-SONAME GENERATIONS ARE TWO RULES, one automatic
  and one declared, because ELF answers the first and cannot answer the second.
  Both are read over the ONE resolution scope the installer composes.
- THE CLOSURE CHECK GATES PACKAGING, with a bounded waiver contract.
- BOTH PROBE READINGS MUST BE CONCLUSIVE when the closure is verified: a
  listing read over the whole search scope, AND a live trace that proves it
  inventoried a venv process. develop#20 answered "no host library loaded" for
  a run that had looked at nothing.
- THE WHEEL SIDE IS ALREADY CLOSED AND MUST STAY CLOSED. develop#24 flagged
  zero of 388 inventoried ELFs once each wheel carried the runtime's search
  list. That acceptance belongs to the completed `relocation-force-rpath`; what
  belongs here is that the closure check keeps it true after a rebuild.

## The one resolution scope, read from the installer rather than assumed

THE ARCHIVE HAS ONE RESOLUTION SCOPE, NOT ONE PER TOOL ROOT. An earlier revision
of this issue said the python and git roots resolve independently and defined a
scope per root. That was assumed from the directory layout and is false.

`build_elf_rpath` at `src/setups/env/bin/install_pkg.sh:881` iterates
`$INSTALL_PREFIX/tools/python` first and then every other `tools/*/`,
accumulating into ONE `dirs` array, dedupes it preserving order, and returns one
colon-joined value. The relocation pass computes that value once at line 959 and
writes it into every ELF it patches. Every shipped object therefore resolves
through the same ordered list, python roots first.

The directories it adds, per tool root, are `root/usr/lib64`, `root/usr/lib`,
`root/lib64`, `root/lib`, plus each version directory's `lib` and `lib64`. IT
NEVER ADDS `root/usr/bin`.

Measured on the live install,
[measurements.resolution-scope.rhel.txt](measurements.resolution-scope.rhel.txt):
ten directories in one scope, spanning `tools/python`, `tools/git` and
`tools/old/py3.13`.

TWO CLASSIFICATIONS IN THE PREVIOUS REVISION WERE WRONG, and both were wrong the
same way, by reading the layout instead of the search list:

| Earlier claim | What the measurement shows |
| --- | --- |
| `libcrypto.so.3` once per tool root is not a collision because the scopes differ | there is ONE scope and both copies are in it. It is not a fault, but because it is the SAME FILE |
| `libssl.so.3` twice per tool root is a collision | one of the two is under `root/usr/bin`, which is not a provider directory in the scope at all |

## Duplicate providers, and the cross-SONAME family, as two separate rules

The previous revision defined family as the SONAME and generation as "a
different SONAME within one family", which cannot both hold: if the family IS
the SONAME then a different SONAME is a different family. ELF carries a
same-SONAME provider identity and no universal logical-family identifier, so the
two relationships need two mechanisms.

### Rule 1, automatic: duplicate providers

CANDIDATES ARE DEFINED BY LOADER LOOKUP, NOT BY INTERNAL SONAME. For a
`DT_NEEDED` entry the loader searches each scope directory IN ORDER for a file
with that EXACT NAME. An object carrying a matching internal `DT_SONAME` under a
different filename is never a candidate unless a path or a symlink exposes it
under the needed name, so it is not a competing provider and this rule ignores
it.

The rule, in the order it must be evaluated:

1. take each `DT_NEEDED` name any shipped object records;
2. collect the paths in the ordered scope where a file of that EXACT NAME
   exists;
3. resolve each path through its links to a real file;
4. compare the DISTINCT resolved targets by SHA-256 over the file bytes.

Two candidates resolving to ONE file are one provider. Two candidates resolving
to DIFFERENT content are a duplicate provider, and packaging REFUSES: the loader
would silently pick the first in scope order, and which one it picks is an
accident of directory order rather than a decision.

MEASURED ON THE CURRENT ARCHIVE,
[measurements.provider-candidates.rhel.txt](measurements.provider-candidates.rhel.txt):
54 distinct `DT_NEEDED` names, 20 of them with more than one candidate path, all
20 resolving to one file, zero resolving to different content. The archive
passes rule 1 today.

AN EARLIER REVISION COUNTED 95 RATHER THAN 20, and the difference is the model
rather than the archive. It grouped by internal `DT_SONAME`, so development
aliases such as `libBrokenLocale.so` beside `libBrokenLocale.so.1` counted as
competing providers. They are not candidates for any lookup. The corrected count
is recorded because the wrong one was published.

### Rule 2, declared: cross-SONAME generations of one family

Two objects with DIFFERENT SONAMEs may still be two generations of one logical
family, and nothing in the files says so. The archive carries the case today:
`libbfd-2.35.2-63.el9.so` and `libbfd-2.35.2-66.el9.so` in the same scope, under
two SONAMEs.

- A FAMILY IS DECLARED, as a named set of SONAME patterns, in the list below,
  committed beside the floor.
- Within one declared family, more generations present in the scope than the
  family permits is REFUSED.
- Nothing is inferred from a filename stem: `libssl.so.1.1` and `libssl.so.3`
  share a stem and are different ABI generations, while a renamed file shares
  no stem with itself.
- An UNDECLARED family is not checked by rule 2 at all. That is deliberate: the
  alternative is a heuristic, and a wrong heuristic here refuses a correct
  archive.

Rule 1 needs no declaration and covers what ELF can answer. Rule 2 covers what
it cannot, and pays for that with an explicit list.

NEITHER RULE PRUNES. A packaging step that deletes a library on its own
judgement is a worse failure than the one it prevents, so both refuse and the
fix is a payload or list change made deliberately.

### The initial declared-family list

This is the configuration rule 2 reads. It is committed beside the floor and
owned by this requirement, on the same terms: a later requirement may add or
change an entry only by saying so in its own document.

| Family | SONAME patterns | Generations permitted in the scope |
| --- | --- | --- |
| `binutils-bfd` | `libbfd-*.so` | 1 |
| `binutils-opcodes` | `libopcodes-*.so` | 1 |

WHY THESE TWO, AND WHY ONLY TWO. They are the families the archive is measured
to carry in more than one generation, or to be one payload change away from it.
`libbfd-2.35.2-63.el9.so` and `libbfd-2.35.2-66.el9.so` are both in the scope
today, in both tool roots, so `binutils-bfd` at one permitted generation REFUSES
the current archive and that refusal is the point: it is a real fault this
requirement exists to surface. `libopcodes` ships one generation today and is
listed beside it because the two travel together in the same RPM set, so a
future divergence is the same fault.

THE LIST IS SHORT ON PURPOSE. Every entry is a claim that two SONAMEs are one
family, and that claim cannot be checked mechanically. A long speculative list
would be a set of unverifiable assertions; a short measured one is a set of
facts about this archive.

AN UNDECLARED FAMILY IS NOT CHECKED, and that is a real limit rather than an
oversight. A future family shipping two generations passes rule 2 until someone
declares it. The alternative is a filename heuristic, which the measurements
show would be wrong in both directions: `libssl.so.1.1` and `libssl.so.3` share
a stem and are different ABI generations, while `libbfd-2.35.2-63.el9.so` and
`libbfd-2.35.2-66.el9.so` share no version-independent stem at all.

## The declared floor

The floor is declared ONCE for the archive, because there is one resolution
scope. An earlier revision declared it per tool root, which followed from the
per-root scope that measurement disproved.

| Floor member | Required location | Why it is on the floor |
| --- | --- | --- |
| `libc.so.6` | anywhere in the scope | the host cache answers for it on the build host |
| `libpthread.so.0`, `libdl.so.2`, `librt.so.1`, `libutil.so.1` | anywhere in the scope | the merged-libc compat stubs manylinux wheels still declare |
| `libstdc++.so.6` | anywhere in the scope | the C++ runtime the wheels' extensions need |
| `libgcc_s.so.1` | anywhere in the scope | its companion, and the object develop#19 wrongly reported absent |
| `libcrypto.so.3`, `libssl.so.3` | anywhere in the scope | the OpenSSL pair |
| `libsqlite3.so.0` | `tools/python` | absent from the root today, and the reason this floor exists |

THE LOCATION COLUMN IS THE OBSERVABLE TEST, and it is the same test everywhere
this document, its questions and the umbrella speak about a floor member. Most
entries read "anywhere in the scope", because resolution is what the floor
protects and the scope is one ordered list. `libsqlite3.so.0` carries a
CONSTRAINT to `tools/python`: its consumer is the interpreter's `_sqlite3`
extension, and a copy living only under the git root would make the python
payload depend on another tool's payload for a library of its own. The
constraint is a hygiene requirement, not a resolution one, and it is stated so
that the floor check, the waiver removal condition and umbrella item 6 all test
the same thing.

WHY THESE AND NOT MORE. The floor holds the members whose absence is INVISIBLE
on the build host, because the host cache answers for them. Everything else is
already caught by the derived half, and a longer floor is only a second list to
keep in step with the payload.

OWNERSHIP IS NAMED. This requirement establishes the floor and the declared
family list beside it. A later requirement may add or remove an entry only by
saying so in its own document; `python-sqlite-support` removes the sqlite waiver
rather than the entry, and `tools-archive-rebuild` may add an entry if the
rebuilt payload introduces one.

## The waiver contract

A waiver is the bounded exception that lets this requirement land before the
payload it enforces arrives. It is not a mute.

- A waiver names EXACTLY ONE floor member, the requirement that removes it, and
  the condition under which it is removed.
- An UNKNOWN waiver, naming a member not on the floor, FAILS packaging.
- A STALE waiver, whose REMOVAL CONDITION IS ALREADY SATISFIED, FAILS packaging.
  The condition is the test, not the owning requirement's state: "is
  `python-sqlite-support` complete" is a document fact with no machine-readable
  source at packaging time, while "is a file named `libsqlite3.so.0` present
  under `tools/python`" is the floor entry's own location test, already
  performed. A waiver excusing a
  member that is now present is dead, and saying so needs nothing new.
- An artifact produced while ANY waiver is active is a VALIDATION ARTIFACT and
  cannot cross the publication boundary. This is what makes the gate mean
  "unpublishable while incomplete" rather than merely "reported".
- Every active waiver is printed by every packaging run.

The one initial waiver:

| Member | Owning requirement | Removal condition |
| --- | --- | --- |
| `libsqlite3.so.0` | `python-sqlite-support`, umbrella item 6 | a file named `libsqlite3.so.0` is present under `tools/python` in the scope, which is the floor entry's own location test |

## The libssl caveat, now measured rather than carried

The umbrella recorded eight `OPENSSL_3.x` nodes the probe reported missing, and
suspected a probe artifact because `import ssl` passes on every run. The round 1
review required that suspicion be settled rather than carried, and it is:
[measurements.openssl-version-nodes.rhel.txt](measurements.openssl-version-nodes.rhel.txt).

- SIX shipped OpenSSL objects were read, every one in the live install;
- the nodes needed by shipped libssl are `OPENSSL_3.0.0`, `3.0.1`, `3.0.3`,
  `3.2.0`, `3.3.0` and `3.4.0`;
- the nodes defined by shipped libcrypto are those six plus `3.0.8`, `3.0.9`,
  `3.1.0` and `3.5.0`;
- VERDICT: every node needed IS defined by a shipped libcrypto. The eight lines
  were an isolation artifact of listing libssl as a root object, exactly as the
  umbrella suspected.

THE COMPARATOR CARRIES ITS OWN CONTROL, and it earned it: the probe's first run
reported all six nodes missing while its own inventory showed them defined,
because the membership test compared a space-delimited pattern against
newline-delimited data and could only ever answer "missing". The verdict is
believed because the control shows it answering both ways.

THE FAMILY CLASSIFICATIONS THIS MEASUREMENT FIRST SUGGESTED WERE WRONG, and the
second measurement says why. Reading directory layout, this issue called
`libssl.so.3` in two directories a collision and `libcrypto.so.3` in two roots a
non-collision on separate scopes. Reading the SEARCH LIST instead,
[measurements.resolution-scope.rhel.txt](measurements.resolution-scope.rhel.txt)
shows `root/usr/bin` is not a provider directory at all and that there is one
scope, not two. The corrected classifications are in "Duplicate providers"
above.

## Gap to close in the implementation for the runtime closure

1. Add a packaging-time check with the two independent membership halves, the
   derived closure and the declared floor, over the whole resolution scope.
2. Add the provider-aware version-need check, including the no-host-fallback
   condition.
3. Add rule 1, over candidates for each exact `DT_NEEDED` lookup name in scope
   order, resolved before their content is compared, and rule 2 over the
   declared family list, both refusing rather than pruning.
4. Implement the waiver contract, including the unknown and stale failures and
   the publication boundary.
5. Declare the initial floor once for the one scope, with the one sqlite waiver,
   and the declared family list beside it.
6. Make the rebuild build against one refreshed sandbox RPM set, so the archive
   cannot diverge from the tree it was packaged from.
7. Make the verification report both readings conclusively, refusing a live
   trace that inventoried no venv process.

## The D10 decision, settled as a conditional policy

D10 is DECIDED by the policy below rather than deferred again. The umbrella
asked for the wheels' C++ demands to be measured during the rebuild; that
measurement is now the policy's input rather than a second decision.

| Element | Value |
| --- | --- |
| consumer set | every shipped ELF in the archive that records a `DT_NEEDED` on `libstdc++.so.6`, measured after the final wheel and dependency set is fixed |
| comparison | `GLIBCXX_` and `CXXABI_` needs against what the shipped `libstdc++` defines, since BOTH namespaces are provided by libstdc++. `libgcc_s` is checked separately, against its own `GCC_` needs |
| switch condition | ship GCC 11 if and only if every required node of both libstdc++ namespaces, and every `GCC_` node required of `libgcc_s`, is defined by the shipped providers; otherwise ship GCC 12 and re-run every check in this issue against the new root |
| neither satisfies | if GCC 12 does not satisfy them either, packaging FAILS and the requirement is not met. The policy selects between two generations; it does not silently accept the closer one |
| spare nodes | ZERO SPARE NODES IS ALLOWED. The condition is satisfaction, not headroom |
| evidence supplied by | `tools-archive-rebuild`, umbrella item 7 |

"Raise the generation when the margin is gone" is deliberately NOT the
threshold: it is ambiguous between zero headroom and an unsupported node, and
only the second is a failure. Today's measured position is that the agent serves
`GLIBCXX_3.4.30` while the shipped GCC 11 `libstdc++` tops out at `3.4.29`, and
no shipped consumer has yet been shown to need `3.4.30`; under this policy that
is a PASS with zero spare nodes, not a trigger.

## Acceptance for the runtime closure

A POSITIVE RESULT ON THE DISTRIBUTION THE DEFECT EXISTS ON, plus one negative
control per independent invariant. A gate nobody has seen fail is a gate nobody
has seen, and this collection has found that three times.

Positive:

- the packaging check passes on the build account, and
- the packaged archive resolves with NO HOST FALLBACK on a Debian 12 container,
  reported from a listing over the whole scope AND a live trace that names the
  venv process it inventoried, and
- THE UNMODIFIED ARCHIVE PASSES RULE 1. This is a positive control rather than a
  formality: 20 of the 54 needed names have more than one candidate path in the
  scope, and all 20 resolve to one file, so a rule 1 that refused the
  same-file case would refuse the current archive 20 times over. The pass
  proves the rule does not over-refuse.

Negative, one fixture per independent invariant, each of which must be REFUSED:

| Invariant | Fixture |
| --- | --- |
| declared floor | a floor member removed from the scope entirely |
| floor location | `libsqlite3.so.0` present in the scope but only under `tools/git`, failing its `tools/python` constraint |
| derived closure | a `DT_NEEDED` that resolves nowhere in the scope |
| provider version need | a version need whose selected provider does not define it |
| no host fallback | a dependency resolvable only from the host cache |
| duplicate provider, rule 1 | two candidate paths for one `DT_NEEDED` name resolving to DIFFERENT content |
| declared family generation, rule 2 | the measured `libbfd-2.35.2-63.el9.so` and `-66.el9.so` pair, which the initial family list refuses today |
| waiver contract | an unknown waiver, and a stale one |
| trace conclusiveness | a trace that inventoried no venv process |

One fixture per invariant is deliberate: exhaustive mutation of every shipped
library would turn acceptance into an implementation test, and one
representative failure would leave most branches unasserted.

## Concrete examples for the runtime closure

- packaging a python root with no `libsqlite3.so.0` and no active waiver for it
  -> REFUSED, naming the absent floor member and its scope
- the same root while the sqlite waiver is active -> packaged as a VALIDATION
  ARTIFACT, the waiver printed, publication refused
- a waiver naming `libsqlite3.so.0` after `python-sqlite-support` is complete
  -> REFUSED as stale
- a shipped `libgcc_s` needing `GLIBC_2.35` that the shipped libc does not
  define -> REFUSED, naming the need, the selected provider and the scope
- shipped libssl needing `OPENSSL_3.4.0`, defined by the shipped libcrypto that
  its scope selects -> ACCEPTED, which is what the retained measurement shows
- `libcrypto.so.3` reachable from the python root and the git root, BYTE
  IDENTICAL -> ACCEPTED. One scope holds both, and rule 1 asks whether they are
  the same file, which they are. 20 needed names in the archive are in this
  position
- two candidate paths for ONE exact `DT_NEEDED` lookup name resolving to objects
  with DIFFERENT digests -> REFUSED, rule 1, naming both paths and both digests
- a second `libssl.so.3` under `root/usr/bin` -> NOT EXAMINED by rule 1, because
  `root/usr/bin` is not a provider directory in the scope
- `libbfd-2.35.2-63.el9.so` and `libbfd-2.35.2-66.el9.so` in the scope, with
  libbfd declared as a family -> REFUSED, rule 2, two generations of one
  declared family
- the same two objects with libbfd NOT declared -> NOT EXAMINED by rule 2. ELF
  says nothing about their kinship and this issue refuses to guess it
- a verification run whose live trace inventoried no venv process -> reported
  INCONCLUSIVE, never as "no host library loaded"

## Code references for the runtime closure

- `src/setups/env/bin/pkg.sh`: packages the toolchain from the build-account
  tree; where the closure, coherence, family and waiver checks belong.
- `src/setups/env/bin/install_pkg.sh`, `build_elf_rpath` at line 881: composes
  the search list from `root/usr/lib64`, `root/usr/lib`, `root/lib64`,
  `root/lib` and each version directory's `lib` and `lib64`, accumulated across
  EVERY tool root into one deduped ordered list. That single composed list IS
  the one resolution scope this issue defines, and it never includes
  `root/usr/bin`.
- `src/setups/pkgs/python/python_rhel_9.8_x86_64.txt`: the sandbox RPM list the
  rebuild must refresh and build against as one set.
- `src/setups/env/bin/pkg_tools.sh`, `src/setups/env/bin/packages_management.sh`:
  the surrounding packaging helpers.

## What this issue does NOT cover

- MAKING THE ROOT RESOLVABLE for dlopen'd wheels through `--force-rpath`. That
  is sub-task 3 of the umbrella's work item 3 and it was umbrella item 2,
  `relocation-force-rpath`, already completed.
- PRODUCING the sqlite payload. That is umbrella item 6,
  `python-sqlite-support`; this issue only makes its arrival enforceable and
  names it as the waiver's remover.
- THE REBUILD AND PUBLICATION. That is umbrella item 7,
  `tools-archive-rebuild`. This issue is validated by REPACKAGING THE CURRENT
  TREE without recompiling anything, and the archive it produces is a
  validation artifact. The published 9.13.4 archive keeps its known
  `GLIBC_2.35` divergence until item 7 clears it, which is recorded here so the
  divergence has a named owner rather than being implied.

## Open questions for the v0.27.0 toolchain-runtime-closure issue

### Q01: what makes the closure "complete"

Question description: the check must know what set it is checking against. A
DERIVED set reads the shipped ELFs and follows every `DT_NEEDED`, so it always
describes the archive in hand. A DECLARED set is a list committed in cplx that
packaging must satisfy, so it describes what the archive is supposed to carry.
A derived set can never notice a library dropped from both the payload and its
consumers, because a dropped library is also one nothing declares any more.
That is the `libsqlite3.so.0` case exactly.

#### BBQ for Q01

A restaurant checks its walk-in before service. One cook checks against
tonight's tickets: if nobody ordered fish, no fish is missing. Another checks
against the printed par list, which says the walk-in carries fish whether or
not tonight's tickets ask for it. Only the second notices the supplier stopped
delivering.

In this picture: the tickets are the shipped objects' `DT_NEEDED` entries, the
shelf is the resolution scope, the par list is the declared floor, the fish is
`libsqlite3.so.0`, and service is the Debian agent.

#### Options for Q01

- Option A1: DERIVED ONLY.
  - pro: exact for the archive in hand, and needs no maintenance.
  - con: blind to a member dropped from payload and consumers together.
- Option A2: DECLARED ONLY.
  - pro: encodes intent and catches a silent drop.
  - con: goes stale, and says nothing about a new demand the payload introduced.
- Option A3: BOTH, AS TWO INDEPENDENT HALVES, with the floor declared ONCE for
  the archive's one resolution scope, every initial member named, and ownership
  of later edits stated.
  - pro: catches both failures, and neither half can pass for the other.
  - pro: one floor matches the one scope the installer composes, measured rather
    than assumed: `build_elf_rpath` accumulates every tool root into a single
    ordered list applied to every ELF.
  - con: two mechanisms to keep working, and a floor that must be revisited
    when the payload changes.

#### Recommended option for Q01 (with arguments for this choice)

Option A3, with the floor now written into the document rather than described:
ONE list for the archive's single scope, ten SONAMEs chosen as exactly those
whose absence is INVISIBLE on the build host because the host cache answers for
them, each carrying its required location. Round 1 was right that "members whose
absence is invisible on RHEL" is a criterion and not a list, so the list is now
present; round 3 was right that a per-root floor followed from a scope model the
measurement disproved. Ownership is named: this requirement establishes it, a
later requirement may add or remove an entry only by saying so in its own
document.

#### Answer to Q01: option A3 (with reason why it must be accepted as the answer)

Option A3. A1 leaves the requirement's headline example outside its own gate.
A2 reintroduces the stale-literal problem this collection has been burned by. A3
with a named floor and a location column is the only form where a reader can
tell, without running anything, what the archive is contracted to carry and
where.

### Q02: does the closure check gate packaging, or report

Question description: a failing check can stop packaging or annotate it. The
difference is whether an incomplete archive can exist and be published by
someone who did not read the report.

#### BBQ for Q02

An unchecked pre-flight item can lock the cabin door or light an amber
annunciator the captain may acknowledge. Both are checklists; only one makes the
failure impossible to fly with.

In this picture: the checklist is the closure check, the flight is publication,
the locked door is packaging refusing, and the amber light is a report beside a
produced archive.

#### Options for Q02

- Option B1: GATE, no exceptions.
  - pro: an incomplete archive cannot exist.
  - con: blocks the ordered transition Q03 describes, for two requirements.
- Option B2: REPORT.
  - pro: never blocks.
  - con: the archive exists and can be published; this collection's history is
    that a report nobody blocks on is a report nobody reads.
- Option B3: GATE WITH A BOUNDED WAIVER CONTRACT. A waiver names exactly one
  floor member, its owning requirement and its removal condition; an unknown or
  stale waiver FAILS; and an artifact produced while any waiver is active is a
  VALIDATION ARTIFACT that cannot cross the publication boundary.
  - pro: keeps the strong default and still allows the ordered transition.
  - pro: the publication rule is what makes "unpublishable while incomplete"
    true rather than asserted.
  - con: a waiver mechanism can be abused as a permanent mute, which the stale
    rule is there to prevent.

#### Recommended option for Q02 (with arguments for this choice)

Option B3 with all four clauses. Round 1 was right that the earlier answer
claimed B3 kept an incomplete archive unpublishable while nothing in it said so:
the publication-boundary clause is what supplies that, and without it B3 is B2
with extra words.

#### Answer to Q02: option B3 (with reason why it must be accepted as the answer)

Option B3. The requirement must land before the payload it enforces arrives
without weakening into a report, and only the bounded contract does both. The
unknown and stale failures keep the exception from becoming a habit.

### Q03: when does `libsqlite3.so.0` become enforced

Question description: this issue is umbrella item 4 and enforces
`libsqlite3.so.0`; `python-sqlite-support` supplies it as item 6. Enforcing on
landing fails packaging for two requirements; not enforcing hands the rule to a
requirement that does not exist yet.

#### BBQ for Q03

An inspector writes a rule that every flat must have a smoke alarm, in a block
whose alarms are installed next quarter. Signing today condemns every flat;
waiting holds nobody to a date; signing with a named commissioning date does
neither.

In this picture: the rule is this requirement, the alarms are the item 6
payload, condemning the flats is packaging failing throughout, and the
commissioning date is the waiver's removal condition.

#### Options for Q03

- Option C1: ENFORCE NOW.
  - pro: no transitional state.
  - con: packaging fails across items 5 and 6, so the declared order is
    unlandable.
- Option C2: ENFORCE LATER, when item 6 lands.
  - pro: never blocks.
  - con: the rule is owed by a requirement that does not exist, which is how the
    library went missing in the first place.
- Option C3: DECLARE NOW, WAIVED, WITH ITEM 6 NAMED as the remover and item 7
  refusing publication while any waiver is active. Recorded in both this issue
  and the umbrella.
  - pro: installing the checker before the expensive sqlite build lets that
    build be checked on its first packaging pass.
  - pro: the hand-off has a machine-checkable exit rather than a memory.
  - con: depends on the Q02 waiver contract, so the two answers stand together.

#### Recommended option for Q03 (with arguments for this choice)

Option C3 rather than resequencing the umbrella. The checker is cheap and the
sqlite build is expensive; ordering the cheap gate first means the expensive
build is measured the first time it runs. Resequencing would invert that and buy
nothing.

#### Answer to Q03: option C3 (with reason why it must be accepted as the answer)

Option C3. It keeps the declared order, gives item 6 a concrete completion
signal, and gives item 7 an explicit refusal condition. The cross-requirement
half is recorded in the umbrella, so neither later item has to rediscover it.

### Q04: which hosts and which controls make the closure acceptable

Question description: a closure gap is invisible on RHEL and fatal on Debian, so
where acceptance is measured decides what a green result is worth. A single
"member removed" control is also not enough once the check has several
independent invariants.

#### BBQ for Q04

A winter tire tested in the July car park is round. The certificate people rely
on comes from the cold chamber. And a chamber that has never recorded a failure
has not been shown to be able to.

In this picture: the car park is the RHEL build account, the cold chamber is the
Debian agent, and a recorded failure is a negative control per invariant.

#### Options for Q04

- Option D1: BUILD ACCOUNT ONLY.
  - pro: cheap.
  - con: proves the check runs, never that its verdict is true where the defect
    exists.
- Option D2: BUILD ACCOUNT PLUS A DEBIAN NO-HOST-FALLBACK RUN.
  - pro: measures the asymmetry the issue is about.
  - con: leaves every gate unasserted.
- Option D3: BOTH, PLUS ONE NEGATIVE CONTROL PER INDEPENDENT INVARIANT: declared
  floor, floor location, derived closure, provider version need, no host
  fallback, duplicate provider (rule 1), declared family generation (rule 2),
  waiver contract, trace conclusiveness.
  - pro: each branch is shown able to refuse.
  - pro: bounded, unlike exhaustive mutation of every shipped library.
  - con: nine fixtures to build and keep working.

#### Recommended option for Q04 (with arguments for this choice)

Option D3 with the per-invariant matrix. Round 1 was right that one removed
member cannot assert the other gates: this check is several checks, and a single
fixture leaves most of them in the state this collection keeps finding, passing
without ever having been able to fail.

#### Answer to Q04: option D3 (with reason why it must be accepted as the answer)

Option D3. The positive Debian run is what makes the verdict true where the
defect lives, and one fixture per invariant is the smallest set that proves each
branch can refuse. Anything less certifies the instrument rather than the
archive.

### Q05: how far does the family-coherence rule reach

Question description: the rule must say which duplicates are faults. The
evidence mixes two conditions: multiple builds of libbfd in one search scope,
and an OpenSSL copy in each tool tree. Identical copies in independent roots are
not two generations, and two ABI-major SONAMEs may be intentional.

#### BBQ for Q05

A library removing duplicate editions can name two known titles, or rule that no
title may sit on the shelf in two editions. The second finds tomorrow's
duplicate. But "the shelf" has to mean one shelf: the same title in two branches
of the library is not a duplicate.

In this picture: a shelf is the one resolution scope, a title is an exact
`DT_NEEDED` lookup name, an edition is a distinct file a candidate path resolves
to, and two branches are the python and git roots.

#### Options for Q05

- Option E1: NAMED FAMILIES ONLY, libbfd and OpenSSL.
  - pro: certain to fix what is measured today.
  - con: the next duplicated family ships silently.
- Option E2: GENERAL RULE, DETECT ONLY.
  - pro: general, and cannot delete something needed.
  - con: a report without a stop, which Q02 rejects.
- Option E3: TWO SEPARATE RULES, DETECT AND REFUSE, over the ONE resolution
  scope: rule 1 refuses two candidate paths for one exact `DT_NEEDED` lookup
  name that resolve to DIFFERENT content, automatically; rule 2 refuses two
  generations of a DECLARED family, from a committed list, because ELF carries
  no logical-family identifier.
  - pro: general, never deletes, and the two mechanisms answer the two different
    questions instead of one rule straddling both.
  - pro: rule 1 needs no declaration and rule 2 admits it needs one, so neither
    guesses.
  - con: rule 2 leaves an undeclared family unchecked, which is a deliberate
    choice against a heuristic that would refuse correct archives.

#### Recommended option for Q05 (with arguments for this choice)

Option E3 as two rules, which is what the measurement forced. Round 2 of the
review was right that "family is the SONAME" and "a generation is a different
SONAME within one family" cannot both hold, and
[measurements.resolution-scope.rhel.txt](measurements.resolution-scope.rhel.txt)
settles why it matters: 20 of the 54 needed names have more than one candidate
path in the one scope and EVERY ONE resolves to the same file. A single rule
keyed on the internal SONAME rather than on candidates for one exact
`DT_NEEDED` lookup name would refuse the current archive 20 times over, all
falsely,
while the genuinely
different case, `libbfd-2.35.2-63.el9.so` beside `libbfd-2.35.2-66.el9.so`, has
two SONAMEs and is invisible to it.

#### Answer to Q05: option E3 (with reason why it must be accepted as the answer)

Option E3 in its two-rule form. It generalises without granting packaging
destructive authority, and each rule now rests on what the format can answer:
content identity for rule 1, an explicit declaration for rule 2. The earlier
single-rule wording was refused for being self-contradictory, and the
measurement shows it would also have been wrong in both directions.

### Q06: is the libssl re-probe inside this requirement or before it

Question description: the umbrella carried eight `OPENSSL_3.x` nodes reported
missing, suspected to be an artifact of listing libssl as a root object. The
prerequisite RPATH work is complete, so the re-probe is now cheap. The question
is whether this requirement performs it, waits on it, or carries the doubt.

#### BBQ for Q06

A survey flags a crack seen through a window at an angle, and notes that
scaffolding, now erected, would settle it. The report can commission the
close-up, treat it as someone else's job, or note the doubt. Only the first
produces an answer.

In this picture: the crack is the eight nodes, the angle is listing libssl as a
root object, the scaffolding is the rpath every shipped library now carries, and
the close-up is the re-probe.

#### Options for Q06

- Option F1: OUT OF SCOPE, carry the caveat.
  - pro: keeps the requirement small.
  - con: leaves an unresolved reading in the requirement whose subject is
    whether the root is coherent.
- Option F2: IN SCOPE, AS A PRECONDITION: re-probe, record the conclusive
  inventory, then write the family and coherence rules against it.
  - pro: the rules are written against a measurement.
  - pro: cheap now that the rpath work is done.
  - con: the requirement carries a measurement as well as a rule.
- Option F3: IN SCOPE, AS AN ACCEPTANCE CASE.
  - pro: strongest evidence.
  - con: a genuine incoherence would block this requirement rather than be
    reported by it.

#### Recommended option for Q06 (with arguments for this choice)

Option F2, and it is DONE:
[measurements.openssl-version-nodes.rhel.txt](measurements.openssl-version-nodes.rhel.txt)
reads all six shipped OpenSSL objects and finds every needed node defined. The
suspicion is settled rather than retained, and the measurement also supplied the
concrete family cases Q05 and Q10 needed.

#### Answer to Q06: option F2 (with reason why it must be accepted as the answer)

Option F2. This collection's repeated lesson is that a reading taken through the
wrong instrument becomes a durable false fact when nobody re-takes it. The
re-probe cost one ssh call and removed the last inherited doubt; its own
comparator needed a control before its verdict could be believed, which is the
same lesson once more.

### Q07: does this requirement re-publish the current archive

Question description: this issue can be validated by repackaging the current
tree without recompiling. Whether that archive is PUBLISHED is a separate
decision from whether it proved the check.

#### BBQ for Q07

A press runs a corrected plate to prove the correction took. Whether that sheet
enters the print run is a separate decision. Confusing the two wastes the proof
or ships an unreviewed sheet.

In this picture: the plate is the packaging check, the proof sheet is the
repackaged current tree, and the print run is what the targets install.

#### Options for Q07

- Option G1: VALIDATION ONLY.
  - pro: no delivery risk.
  - con: the published archive keeps its known divergence with nothing saying so.
- Option G2: REPUBLISH.
  - pro: the divergence stops shipping.
  - con: publishes an archive nobody rebuilt, and item 7 owns publication.
- Option G3: VALIDATION ONLY, WITH THE DIVERGENCE RECORDED AS OWED, AND
  PUBLICATION REFUSED WHILE ANY WAIVER IS ACTIVE.
  - pro: keeps the packaging and publishing boundary the umbrella draws.
  - pro: the refusal is mechanical, so recording the divergence is not the only
    thing standing between it and delivery.
  - con: the divergence stays shipped until item 7.

#### Recommended option for Q07 (with arguments for this choice)

Option G3 with the publication refusal. Round 1 was right that merely recording
a known divergence does not prevent accidental delivery; the Q02 waiver clause
is what does, and G3 now names it rather than relying on the record.

#### Answer to Q07: option G3 (with reason why it must be accepted as the answer)

Option G3. It preserves the umbrella's division of labour, keeps this
requirement orderable before the rebuild, and replaces a note with a rule.

### Q08: what does D10 commit this requirement to

Question description: the umbrella defers D10, the C++ runtime generation
shipped in the root, to be settled inside this requirement. A deferral restated
is not a settlement, so the answer must be a policy with an unambiguous switch.

#### BBQ for Q08

A ferry rated for vehicles up to a stated height clears today's traffic by a
hand's width. The operator can keep the rating and turn away the first taller
lorry, or raise the deck while in dock. What decides it is the measured height
of the lorries actually queueing, and "the margin is gone" is not a measurement:
a lorry that exactly fits still fits.

In this picture: the rating is what the shipped `libstdc++` and `libgcc_s`
define, the lorries are the shipped C++ consumers, being in dock is the rebuild,
and the queue measurement is reading their `GLIBCXX_` and `CXXABI_` needs.

#### Options for Q08

- Option H1: KEEP GCC 11 unconditionally.
  - pro: matches the deployment servers exactly and costs nothing.
  - con: drops the trigger the umbrella asked this requirement to carry.
- Option H2: SHIP GCC 12 unconditionally.
  - pro: absorbs a wheel set that moves past the current node.
  - con: adds a payload to a requirement whose value is needing no recompile,
    and the servers do not carry that generation themselves.
- Option H3: A DECIDED CONDITIONAL POLICY. The consumer set is every shipped ELF
  with a `DT_NEEDED` on `libstdc++.so.6`, measured after the final wheel and
  dependency set is fixed; `GLIBCXX_` and `CXXABI_` are BOTH compared against
  what the shipped libstdc++ defines, since libstdc++ provides both, while
  `libgcc_s` is checked separately against its own `GCC_` needs; ship GCC 11 if
  and only if every one of those is satisfied, otherwise ship GCC 12 and re-run
  every check here; if NEITHER generation satisfies them, packaging FAILS rather
  than taking the closer one; ZERO SPARE NODES IS ALLOWED. Item 7 supplies the
  evidence.
  - pro: settles D10 as a rule rather than deferring it again.
  - pro: the threshold is satisfaction, which is measurable, rather than
    headroom, which is not a failure.
  - con: the answer is not known until the rebuild measures the consumer set.

#### Recommended option for Q08 (with arguments for this choice)

Option H3 as rewritten twice. Round 1 was right that the first H3 did not settle
anything: "raise the generation when the margin is gone" is ambiguous between
zero headroom and an unsupported node, and only the second is a failure. Under
the stated policy today's position, `3.4.30` served by the agent against a
shipped ceiling of `3.4.29` with no shipped consumer needing `3.4.30`, is a PASS
with zero spare nodes.

#### Answer to Q08: option H3 (with reason why it must be accepted as the answer)

Option H3. It is a decision, not a deferral: the consumer set, the two
namespaces, the switch condition and the spare-node rule are all fixed here, and
only the measurement is supplied later. The umbrella's D10 row is updated to
record that.

### Q09: what does version-node coherence actually mean

Question description: the issue's original rule said every version node demanded
by a shipped library must be defined by the shipped libc. That is false for its
own examples: `GLIBCXX_` and `CXXABI_` are defined by libstdc++ and `OPENSSL_`
by libcrypto. The rule needs a correct form before anything implements it.

#### BBQ for Q09

A parts inspector checks that every bolt a machine calls for is in the crate.
One inspector looks only in the fasteners box, because that is where bolts live,
and rejects a machine whose bolt came bundled with its bracket. Another follows
the parts list to the box each item was actually assigned to.

In this picture: the machine is a shipped object, a bolt is a version need, the
fasteners box is libc, the parts list is `DT_NEEDED`, and following it is
provider resolution.

#### Options for Q09

- Option J1: LIBC ONLY, the original wording.
  - pro: simple, and correct for `GLIBC_`.
  - con: false for every other namespace; would reject coherent OpenSSL and C++
    pairs.
- Option J2: NAMESPACE-TO-FAMILY MAPPING, a table from `GLIBC_` to libc,
  `GLIBCXX_` to libstdc++, `OPENSSL_` to libcrypto.
  - pro: correct for the known namespaces.
  - con: a hand-maintained table that is silently wrong for the first namespace
    nobody listed.
- Option J3: ACTUAL `DT_VERNEED` PROVIDER RESOLUTION. Each version need is
  recorded against a named provider; resolve that provider through the archive's
  own search scope, require the selected object to define the node, and require
  the resolution to stay inside the archive.
  - pro: correct for every namespace, including ones nobody has met.
  - pro: the no-host-fallback condition falls out of it rather than being a
    separate rule.
  - con: the check must resolve like the loader does, which is more than reading
    a table.

#### Recommended option for Q09 (with arguments for this choice)

Option J3. The ELF format already records which provider each need belongs to,
so a mapping table re-derives, less reliably, information the file carries. J3
is also the only option that expresses the condition the build host cannot
answer: that resolution never leaves the archive.

#### Answer to Q09: option J3 (with reason why it must be accepted as the answer)

Option J3. J1 is the defect this question exists to correct. J2 is right until
the first unlisted namespace, and this requirement's whole subject is a gap that
was invisible until it was fatal. J3 reads what the objects state about
themselves.

### Q10: how are a family and a generation identified, and over which scope

Question description: the family rule cannot be implemented while family,
generation, pair and scope are undefined. The evidence contains three distinct
shapes and a single "duplicate" notion collapses them.

#### BBQ for Q10

A warehouse flags duplicates. Two boxes with the same label on one aisle is a
problem: a picker must choose. The same label on two different aisles serving
two different shops is not. And two boxes deliberately labelled v1 and v2 are a
policy, not an accident.

In this picture: an aisle is a resolution scope, a label is a SONAME, choosing
is what the loader does, two shops are the python and git roots, and v1 and v2
are ABI-major generations.

#### Options for Q10

- Option K1: A HARD-CODED KNOWN-FAMILY LIST, libbfd and OpenSSL.
  - pro: certain for today's evidence.
  - con: silent for everything else, and the list needs an owner.
- Option K2: A FILENAME HEURISTIC on the stem before the version suffix.
  - pro: needs no metadata.
  - con: wrong in both directions; `libssl.so.3` and `libssl.so.1.1` share a
    stem and are different ABI generations of one family, while a renamed file
    is invisible.
- Option K3: TWO IDENTITIES, EACH FROM WHAT CAN ANSWER IT. Provider identity is
  the exact `DT_NEEDED` lookup name, and two candidates are the SAME provider
  when they resolve to content with equal digests; that is rule 1 and it needs
  no declaration. Logical-family identity across
  DIFFERENT SONAMEs cannot be read from ELF at all, so it is a committed
  declaration of SONAME patterns; that is rule 2. Scope is the one ordered list
  the installer composes.
  - pro: each identity comes from a source that can actually supply it, instead
    of one definition trying to be both.
  - pro: classifies every measured shape correctly, including the 20 same-file
    candidate sets that a rule keyed on the internal SONAME would refuse.
  - con: an undeclared family is unchecked, and the declaration needs an owner.

#### Recommended option for Q10 (with arguments for this choice)

Option K3 in its two-identity form. Round 2 of the review was right that the
previous wording was impossible: family cannot be the SONAME while a generation
is a different SONAME within one family. The measurement then showed both
directions of the error mattered. `libcrypto.so.3` reachable from the python and
git roots is ONE FILE, not two, so it is not a fault; `libssl.so.3` under
`root/usr/bin` is not in the scope at all, since `build_elf_rpath` never adds
that directory; and `libbfd` ships two generations under two SONAMEs, which no
SONAME rule can see.

#### Answer to Q10: option K3 (with reason why it must be accepted as the answer)

Option K3. It is the only option whose identities are obtainable: content
digests are readable and a cross-SONAME kinship is not. K1 hard-codes what the
declaration should carry, K2's filename stem is wrong in both directions, and
the previous single definition was refused for contradicting itself. This
answer's classifications are measured rather than asserted, which the previous
answer's were not.

### Q11: what negative evidence proves the combined gate

Question description: the check is several independent invariants sharing one
entry point. The acceptance must say how much failure evidence is required
before a green is believed, without turning acceptance into an exhaustive
implementation test.

#### BBQ for Q11

A building's alarm has smoke, heat and manual-call inputs. Testing smoke proves
the siren works and says nothing about the other two. Burning the building
proves everything and leaves nothing. One test per input is the bounded middle.

In this picture: the siren is packaging refusing, the inputs are the independent
invariants, and burning the building is mutating every shipped library.

#### Options for Q11

- Option L1: ONE REPRESENTATIVE FAILURE.
  - pro: cheapest.
  - con: proves one branch and leaves the rest unasserted, which is exactly what
    round 1 refused.
- Option L2: ONE FIXTURE PER INDEPENDENT INVARIANT: declared floor, floor
  location, derived closure, provider version need, no host fallback, duplicate
  provider (rule 1), declared family generation (rule 2), waiver contract, trace
  conclusiveness.
  - pro: every branch is shown able to refuse.
  - pro: bounded and stable, since the invariant count changes only when the
    rule does.
  - con: nine fixtures to build and maintain.
- Option L3: EXHAUSTIVE MUTATION of every shipped library.
  - pro: maximal coverage.
  - con: turns acceptance into an implementation test and costs a run per
    object, hundreds of them.

#### Recommended option for Q11 (with arguments for this choice)

Option L2. The invariants are independent, so the count of fixtures is the count
of ways the gate can be wrong, and that is the natural unit. L3 measures the
implementation rather than the requirement.

#### Answer to Q11: option L2 (with reason why it must be accepted as the answer)

Option L2. This collection has three recorded cases of a gate that passed
because it could not fail, and each was found by a control rather than by
review. One control per invariant is the smallest set that closes that class
here, and the acceptance table names all nine. Round 3 of the review asked for
eight, counting the split of the family check into rules 1 and 2; the ninth is
the floor LOCATION constraint added in the same round, which is independently
refusable and therefore independently assertable.
