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

## Requirement clarifications for the runtime closure

Eleven questions were opened and settled across four specification review
rounds. Each row names the question, the decision, where it lives in this
document, and what was rejected. The options weighed, their pros and cons, and
the acceptance reason for each answer are preserved in commit `6c8d6ed`,
recorded immediately before this table replaced them.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | Completeness is TWO independent halves: the derived `DT_NEEDED` closure AND a declared floor of ten SONAMEs, each with a required location, declared once for the archive's single scope | "Confirmed rules", "The declared floor" | A1, derived only, which cannot see a member dropped from payload and consumers together, the `libsqlite3.so.0` shape; A2, declared only, which goes stale and misses a new demand |
| Q02 | The check GATES packaging, with a bounded waiver contract: one member per waiver, unknown and stale waivers fail, and any artifact produced under an active waiver is validation-only and cannot be published | "The waiver contract" | B1, an unconditional gate, which makes the declared umbrella order unlandable; B2, a report, the decorative-gate shape this collection exists to remove |
| Q03 | `libsqlite3.so.0` is declared on the floor NOW and waived, with `python-sqlite-support` named as remover and `tools-archive-rebuild` refusing publication while any waiver is active | "The waiver contract", umbrella items 6 and 7 | C1, enforcing immediately, which fails packaging across two requirements; C2, enforcing later, which hands the rule to a requirement that does not exist yet |
| Q04 | Acceptance is a positive Debian no-host-fallback run PLUS one negative control per independent invariant, nine of them | "Acceptance for the runtime closure" | D1, the build account alone, which cannot see the defect; D2, both hosts with no controls, which leaves every gate unasserted |
| Q05 | Two separate rules, both refusing and neither pruning: rule 1 automatic over lookup candidates, rule 2 over a declared family list | "Duplicate providers, and the cross-SONAME family" | E1, two named families only, which leaves the next one silent; E2, detect without stopping, which Q02 already rejected |
| Q06 | The post-RPATH OpenSSL re-probe is performed INSIDE this requirement, as a precondition to writing the rules, not carried as a caveat | "The libssl caveat, now measured rather than carried" | F1, out of scope, leaving an unresolved reading in the requirement about coherence; F3, as an acceptance case, which would block this requirement on an outcome it does not control |
| Q07 | Validation only: the repackaged current tree is never published, the known `GLIBC_2.35` divergence is recorded as owed to item 7, and publication is refused mechanically while a waiver is active | "What this issue does NOT cover", "The waiver contract" | G1, validation only with the divergence merely noted, which leaves nothing preventing delivery; G2, republishing, which takes work item 7 owns |
| Q08 | D10 is DECIDED as a conditional policy: measure every shipped consumer of `libstdc++.so.6`, compare `GLIBCXX_` and `CXXABI_` against the shipped libstdc++ and `GCC_` against `libgcc_s`, ship GCC 11 only if all are satisfied, zero spare nodes allowed, and FAIL if neither generation satisfies | "The D10 decision, settled as a conditional policy", umbrella row D10 | H1, keeping GCC 11 unconditionally, which drops the trigger the umbrella asked this requirement to carry; H2, shipping GCC 12 unconditionally, which adds a payload to a requirement that needs no recompile |
| Q09 | Version-node coherence is PROVIDER-AWARE: each need is resolved to the shipped object the scope selects for its recorded `DT_NEEDED`, that object must define the node, and no step may fall back to the host | "The provider-aware coherence rule" | J1, libc only, which is false for `GLIBCXX_`, `CXXABI_` and `OPENSSL_`; J2, a namespace-to-family table, which is silently wrong for the first namespace nobody listed |
| Q10 | Two identities, each from a source that can supply it: provider identity is the exact `DT_NEEDED` lookup name with content-digest comparison, and cross-SONAME kinship is a committed declaration | "Duplicate providers, and the cross-SONAME family", "The initial declared-family list" | K1, a hard-coded known-family list, which hard-codes what the declaration should carry; K2, a filename stem, wrong in both directions on the measured evidence |
| Q11 | One negative fixture per independent invariant | "Acceptance for the runtime closure" | L1, one representative failure, which leaves most branches unasserted; L3, exhaustive mutation of every shipped library, which turns acceptance into an implementation test |

### What the four rounds kept finding

Recorded because it shaped six of the eleven answers and should outlive the
questions that produced them. Every round found the same defect one layer
further in: a rule stated against the wrong provider (Q09), a classifier that
contradicted itself (Q10), a family list promised in four places and never
written, a stale test with no machine-readable source, and a candidate model
that was not the loader's.

THREE OF THOSE WERE MEASUREMENTS READ WRONG RATHER THAN MISSING, which is the
harder failure. The OpenSSL nodes were reported absent by a probe whose own
comparator could only answer "missing". The scope was inferred from directory
layout instead of from the composed search list. The duplicate-provider count
was taken over internal SONAMEs instead of over lookup names, and reported 95
where the loader sees 20.

Each is a reading that looked like evidence and was not, which is the same
defect class the requirement itself exists to close in the archive. The three
retained measurements are kept beside this document so a later reader checks
the numbers rather than inheriting them.

