# Design v0.27.0 -- Ship a complete runtime closure in the archive

Reference issue: [issue.v0.27.0.toolchain-runtime-closure.md](issue.v0.27.0.toolchain-runtime-closure.md)
Reference umbrella: [draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md), item 4
Reference environments: [reference.environments.md](reference.environments.md)

---

## Context for v0.27.0 toolchain-runtime-closure

The issue settles WHAT the archive owes: a guarantee that a future packaging run
cannot ship an incomplete or incoherent root silently. It settles it as four
invariants, a bounded waiver contract, a declared configuration and an evidence
model, across eleven clarifications.

This design settles HOW those invariants are expressed as one mechanism. It has
one hard problem, and the rest follows from solving it: THE INVARIANTS ARE
DEFINED OVER A SEARCH SCOPE THAT DOES NOT EXIST YET AT THE MOMENT THEY MUST BE
CHECKED.

## Scope for v0.27.0 toolchain-runtime-closure

The v0.27.0 outcomes are:

1. two scopes kept apart: a DECLARED candidate shape derived from declared
   roots, their declared immediate subdirectories and fixed suffixes, and the
   OBSERVED LOADER SCOPE that resolution actually uses, with typed results for
   the difference and each result refused by an actor that can observe it;
2. four independent invariants over that scope, each able to refuse on its own
   and each independently assertable, over a subject set that includes every
   shipped ELF rather than only the ones a static walk can reach;
3. a declared configuration, the roots, the floor, the family list and the
   waivers, carrying the claims no format can supply, with a defined digest and
   an authoritative source that PUBLICATION RESOLVES FOR ITSELF rather than
   reading from the archive;
4. a waiver model whose exceptions are bounded, observable and unable to reach
   publication;
5. the interface through which the D10 policy the issue already decided consumes
   the evidence umbrella item 7 produces;
6. an ARCHIVE IDENTITY, and one verification result keyed to it, so publication
   can prove the cross-root comparison it requires was taken over the exact
   bytes it is about to publish.

Everything else is either supporting design context for those outcomes or
explicitly deferred.

### In scope for v0.27.0 toolchain-runtime-closure

- the candidate shape derivation, the observed loader scope beside it, the two
  evaluation contexts, and which actor may produce each typed result
- the four invariants, their subject sets, their inputs, and what each refuses
- the declared configuration as data, its digest domain, its immutable source,
  and what makes it authoritative rather than merely self-describing
- the waiver lifecycle and the publication boundary, including what publication
  re-evaluates, against which configuration, and in what order
- the evidence model: which host answers which half, how results aggregate, when
  a result is genuinely unavailable, and the control matrix
- the archive identity, what the verification result records, and how publication
  proves that result belongs to the archive in hand
- the D10 evidence-to-policy interface: the reading item 7 supplies, the
  comparison it feeds, and the three results the policy returns

### Deferred from v0.27.0 toolchain-runtime-closure to later items

- producing the sqlite payload, which is umbrella item 6
- the rebuild and the publication of a new archive, which is umbrella item 7
- TAKING the D10 measurement, which is item 7's work. Its interface is designed
  here rather than deferred with it, because a policy whose input is undefined
  is not a decided policy.

---

## Confirmed Technical Facts for v0.27.0 toolchain-runtime-closure

These facts were confirmed by reading the current sources and by four retained
measurements taken on the deployment target.

**The search scope is composed once, at install time, across every tool root**:
`build_elf_rpath` at `src/setups/env/bin/install_pkg.sh:881` walks
`$INSTALL_PREFIX/tools/python` first and then every other `tools/*/`, adding
each root's `root/usr/lib64`, `root/usr/lib`, `root/lib64`, `root/lib` and each
version directory's `lib` and `lib64`. It dedupes preserving order and returns
one colon-joined value, computed once at line 959 and written into every ELF the
relocation pass patches. It never adds `root/usr/bin`.

**That composition is existence-sensitive**: `build_elf_rpath` tests each
candidate directory with `[ -d ... ]` before adding it. The value it returns is
therefore the OBSERVED subset of a larger candidate set, not the candidate set
itself. This is correct for the loader, which cannot search a directory that is
not there, and it is why this design separates the two.

**It discovers TWO things from the filesystem, not one**: the tool roots, by
globbing `"$INSTALL_PREFIX"/tools/*/` at line 888, and EVERY IMMEDIATE
SUBDIRECTORY of each root, by globbing `"$tool_dir"/*/` at line 894. The second
loop is not restricted to version-shaped names, so a declaration listing only
the roots cannot produce the directories the loader actually gets, WHICH IS WHY
THE IMMEDIATE SUBDIRECTORIES ARE DECLARED TOO. The loop also revisits `root/`,
whose `lib` and `lib64` the suffix loop already added, and the dedupe absorbs
it.

**Two of the measured directories are one directory under two names**:
[measurements.resolution-scope.rhel.txt](measurements.resolution-scope.rhel.txt)
entries 4 and 5 are `tools/python/current/lib` and
`tools/python/python-3.13.9/lib`. `current` is an ALIAS, not a version, and it
is on the rpath in its own right because the loop adds every subdirectory. This
is why the declaration is a subdirectory list rather than a version list, and it
is also a case rule 1 must ACCEPT: two candidate paths, one file, one provider.

**The measured scope has ten directories and spans three tool roots**:
[measurements.resolution-scope.rhel.txt](measurements.resolution-scope.rhel.txt)
reads it on the live install, including `tools/old/py3.13`. This is what makes
the scope a property of the archive rather than of a tool.

**Packaging runs before any of that exists**: `pkg.sh` archives `$HOME/<folder>`
from the build account's live tree. No rpath has been written, no
`$INSTALL_PREFIX` is known, and the ELFs still carry the build account's paths.
THIS IS THE CENTRAL CONSTRAINT OF THIS DESIGN.

**Provider candidates are lookup names, not internal SONAMEs**:
[measurements.provider-candidates.rhel.txt](measurements.provider-candidates.rhel.txt)
counts 54 distinct `DT_NEEDED` names required, 20 of them with more than one
candidate path, all 20 resolving to one file. Counted by internal `DT_SONAME`
instead, the same archive reports 95, because development aliases such as
`libBrokenLocale.so` beside `libBrokenLocale.so.1` are not candidates for any
lookup.

**A `DT_NEEDED` walk from the entry points reaches a minority of the shipped
objects**:
[measurements.closure-subjects.rhel.txt](measurements.closure-subjects.rhel.txt)
walks the transitive closure from 185 entry points, matching names anywhere in
the tree so that no stricter rule could reach more. It reaches 176 names and
does NOT reach 395 of the 628 shipped ELFs, including 76 CPython extension
modules under `lib-dynload` and 28 under `site-packages`, and NO shipped object
declares any of them in a `DT_NEEDED`. CPython opens them by path at import
time. THIS IS WHY THE SUBJECT SET IS EVERY SHIPPED ELF.

**Version needs name their own provider**: each `DT_VERNEED` entry records the
file it belongs to, so `GLIBC_` belongs to libc, `GLIBCXX_` and `CXXABI_` to
libstdc++, `OPENSSL_` to libcrypto. The archive's OpenSSL pair is coherent,
measured in
[measurements.openssl-version-nodes.rhel.txt](measurements.openssl-version-nodes.rhel.txt).

**One declared family is violated today**: `libbfd-2.35.2-63.el9.so` and
`libbfd-2.35.2-66.el9.so` are both in the scope, under two SONAMEs, in both tool
roots.

---

## Current Behavior for v0.27.0 toolchain-runtime-closure

```txt
build account tree                      target
------------------                      ------
pkg.sh  --tar-->  archive  --install_pkg.sh-->  relocated tree
   |                                                  |
   no check                                    build_elf_rpath
                                                      |
                                              rpath written per ELF
                                                      |
                                        anything unresolved -> host ld.so.cache
```

Nothing between the tree and the archive asks what the archive must carry, and
nothing after it asks whether what it carries agrees with itself. The first
observation of a gap is a process dying on the Debian agent, one delivery later.

## Target Behavior for v0.27.0 toolchain-runtime-closure

TWO MECHANISMS, NOT ONE. The STATIC CHECKER runs in both contexts and owns the
four archive invariants. The LIVE OBSERVER runs only on the foreign host and
owns process inventory and actual host fallback. Verification composes their two
typed results; packaging composes nothing, because only one of them ran.

```txt
build account tree                          target, Debian agent
------------------                          --------------------
read config from cplx at a commit               relocated tree
   |                                                  |
declared candidate shape                     check bundle against its own
   |                                          digest: consistency only
observe under THIS root, refuse UNEXPECTED            |
   |                                          declared candidate shape
STATIC CHECKER, four invariants                       |
   |                                          observe under THIS root,
   refuse --> no archive                       refuse UNEXPECTED
   |                                                  |
   pass, or pass with active waivers           observe the ARCHIVE contents too,
   |                                            before installing
archive + bundle  ------------------------>           |
   |                                          COMPARE the two: refuse DIVERGENT
   (the local observation stays here,                 |
    nothing downstream trusts it)             STATIC CHECKER, four invariants
                                                      |
                                              LIVE OBSERVER, one named process
                                                      |
                                              RESULT keyed by the ARCHIVE DIGEST
publication, umbrella item 7:                         |
COMPUTE the archive digest itself,      <-------------+
RESOLVE the config from cplx itself,
require the envelope digest to match,
require a result keyed to THAT digest,
re-run the static checker over THIS archive
against THE RESOLVED config,
refuse on any active waiver
```

THE SAME FOUR INVARIANTS RUN TWICE, over a shape declared once and observed
against two different roots. THREE THINGS ARE DELIBERATELY NOT WHERE THEY LOOK
LIKE THEY BELONG. Packaging does not refuse DIVERGENT, because it has seen one
tree, and its local observation is never transported: VERIFICATION DERIVES BOTH
SIDES, one from the archive it holds and one from the tree it installed.
Publication does not read the archive's configuration, because an archive cannot
certify its own contract; it resolves the authoritative one from cplx. And
publication does not read the archive's identity either; it computes it, which
is what lets it require a comparison taken over exactly these bytes.

PACKAGING MAKES NO CLAIM ABOUT RUNTIME HOST FALLBACK: only a running process
shows it. Its verdict is explicitly partial, and saying so is what keeps a green
packaging run from reading as a complete answer.

---

## Design Area 1 for v0.27.0 toolchain-runtime-closure: two scopes, and who may compare them

### The candidate shape is declared; the loader scope is observed

`build_elf_rpath` produces absolute directories because the loader needs them,
and it discovers TWO things from the filesystem rather than one: the tool roots,
by globbing `tools/*/`, and EVERY IMMEDIATE SUBDIRECTORY of each root, by
globbing `$tool_dir/*/`. A declaration listing only `python` and `git` therefore
cannot produce `tools/python/python-3.13.9/lib`, and round 2 was wrong to imply
it could. Nor is the second loop about versions: the measured scope contains
`tools/python/current/lib`, an alias, beside the versioned directory it points
at.

The design carries two scopes, and keeping them apart is what makes the rest
consistent.

THE DECLARED CANDIDATE SHAPE is root-independent and touches no filesystem. It
is the product of three declared inputs:

| Input | Declared as | Contributes |
| --- | --- | --- |
| tool roots | an ordered list, python first | one root each |
| immediate subdirectories, per root | an explicit list per root, whatever their names: the measured `python` root declares `current` and `python-3.13.9`, one an alias and one a version | one directory each |
| relative suffixes | fixed by this design, not configurable | `root/usr/lib64`, `root/usr/lib`, `root/lib64`, `root/lib` per root, and `lib`, `lib64` per declared subdirectory |

THE SECOND ROW IS A SUBDIRECTORY LIST, NOT A VERSION LIST. The installer loop
adds every immediate subdirectory it finds, so a declaration that enumerated
only version-shaped names would leave `current` UNEXPECTED and refuse a tree
that is correct. `root/` is a declared subdirectory of every root by
construction, and the dedupe absorbs its duplicate contribution exactly as the
installer's does.

The order is the loader's order: python's root suffixes first, then python's
declared subdirectories, then each remaining declared root the same way, deduped
preserving first occurrence.

THE OBSERVED LOADER SCOPE is what `build_elf_rpath` actually produces over a
real tree: every `tools/*/` root it finds, declared or not, every subdirectory
of each, and the existing suffixes among them. This is what the loader searches,
so it is what resolution is evaluated against. Nothing is resolved through a
directory the loader would not search, and nothing the loader would search is
excluded from resolution.

RESOLUTION USES THE OBSERVED LOADER SCOPE. EXPECTATIONS ARE STATED AGAINST THE
DECLARED CANDIDATE SHAPE. Every element of the observed scope that the declared
shape does not contain is UNEXPECTED, and that is a refusal.

### Typed results, and which actor can produce each

| Observation | Result | Who can observe it |
| --- | --- | --- |
| a declared candidate directory exists under this root | PRESENT | either context, locally |
| a declared candidate directory is absent under this root | ABSENT, reported, not fatal on its own | either context, locally |
| an observed loader directory the declared shape does not contain, whether an undeclared root or an undeclared subdirectory | UNEXPECTED, refusal | either context, locally |
| a directory PRESENT in the archive and ABSENT under the installed root, or the reverse | DIVERGENT, refusal | ONLY an actor holding both observations |

THE LAST ROW IS THE ONE ROUND 2 PUT IN THE WRONG PLACE. Packaging runs before
any installed root exists, so it cannot know that a directory will later be
missing there, and a design that asked it to refuse DIVERGENT was asking it to
refuse a fact it cannot observe.

### Where the comparison actually happens

| Actor | Does | Cannot do |
| --- | --- | --- |
| packaging | derives the declared shape, observes presence under the build tree, refuses UNEXPECTED | compare against an installed tree that does not exist |
| verification | derives the declared shape TWICE against the one archive it holds: once over the archive's contents BEFORE installing, once over the installed tree. Refuses UNEXPECTED on either, compares the two, and refuses DIVERGENT | nothing here it cannot do; it holds both sides |
| publication | recomputes the archive digest and requires a verification result keyed to THAT digest, present and passing | accept an archive whose comparison was never taken, or one taken over different bytes |

PACKAGING'S OBSERVATION IS LOCAL AND IS NOT TRANSPORTED. It is an early, cheap
gate that refuses an UNEXPECTED directory before a tar is built, and nothing
downstream trusts it or needs to.

THE BUILD-SIDE HALF OF THE COMPARISON IS DERIVED BY VERIFICATION, from the exact
archive it is about to install. That is not merely cheaper than transporting a
packaging claim: it is more correct. What DIVERGENT must compare is WHAT THE
ARCHIVE CARRIES against what the installed tree has, and a directory that existed
on the build account but was never archived is precisely the divergence worth
catching. Design Area 7 states the identity that ties the resulting comparison
to one archive.

### One derivation, two callers

The declared candidate shape must be derived by ONE rule taking the declared
inputs, not by two implementations that agree today. The failure this
requirement exists to prevent is a gap invisible where it is created and fatal
where it is used; two derivations that drift would reproduce it one level up.
How the sharing is expressed is an implementation concern; that exactly one
definition exists is not.

### Declared roots, declared subdirectories, and the measured `old/` root

The initial declaration is `python` and `git`, with their declared immediate
subdirectories, which for `python` are `root`, `current` and `python-3.13.9`.
The measured tree contains a third root, `tools/old/py3.13`, on the rpath of
every relocated ELF.

`old/` is UNEXPECTED, so packaging refuses and names it. THE REFUSAL IS NOT
WAIVABLE. The issue settled a waiver contract whose subjects are floor members,
and this design does not amend it: an undeclared root is repaired by removing
the root or by declaring it, and neither repair is blocked on another umbrella
item, so nothing here needs the ordered transition a waiver exists to buy.

The archive as it stands therefore fails this check until `old/` is removed from
the build tree or added to the declared roots with its subdirectories. That
is deliberate. A superseded interpreter root on the rpath of every shipped
object is a finding, and the alternative, silently counting it as scope, would
let a floor member present only under `old/` satisfy the floor. Because it is in
the OBSERVED loader scope, a lookup can still resolve there, so the refusal is
also the only thing stopping that resolution from counting.

### What the shape excludes, and why it is worth stating

`root/usr/bin` holds ELF objects, including a second `libssl.so.3`, and is
neither a declared candidate nor part of the observed loader scope:
`build_elf_rpath` never adds it. Objects there are not providers, and no
invariant may treat them as such. They remain SUBJECTS, which Design Area 2
separates from providers.

## Design Area 2 for v0.27.0 toolchain-runtime-closure: four sets, then four invariants

### Four sets, kept apart

The previous revision used one word, "shipped object", for four different
things. They are separated here because three of the round 1 findings were
consequences of running them together.

| Set | What it is | Where it comes from |
| --- | --- | --- |
| PROVIDER DIRECTORIES | where a lookup may find a candidate | the observed loader scope |
| STATIC SUBJECTS | every ELF whose recorded dependencies must resolve | every ELF in the archive, however it is loaded |
| RUNTIME ENTRY POINTS | where execution can begin | declared: the interpreter, the shipped executables, and the declared dynamically loaded locations |
| LIVE OBSERVATIONS | what one real process actually loaded | the trace, on the foreign host only |

### The static subject set is every shipped ELF, and the measurement says why

STATIC SUBJECTS ARE EVERY ELF THE ARCHIVE SHIPS. Not the transitive `DT_NEEDED`
closure from the entry points, which is what an earlier revision proposed and
what the design review refused.

The refusal is measured, not argued:
[measurements.closure-subjects.rhel.txt](measurements.closure-subjects.rhel.txt)
walks the transitive closure from 185 entry points, deliberately matching names
anywhere in the tree so that no stricter rule could reach more. It reaches 176
names and MISSES 395 of the 628 shipped ELFs, among them 76 CPython extension
modules under `lib-dynload` and 28 under `site-packages`. No shipped object
declares any of them: the interpreter opens them by path at import time.

A subject set built from that walk would therefore have examined none of the
objects whose failures motivated this entire cross-distribution effort. The
pymupdf and manylinux wheel cases live entirely inside the gap.

AN UNREFERENCED SHIPPED ELF IS STILL A SUBJECT, and its being unreferenced is
its own reported result rather than an exclusion. It is examined, and separately
noted as reached by no entry point and by no `DT_NEEDED` edge, because "the
archive ships something nothing can load" is worth saying and is not a reason to
stop checking it.

### Membership, in two halves that cannot substitute for each other

The DERIVED half asks whether every `DT_NEEDED` name recorded by every static
subject resolves to a file in the provider directories. The DECLARED half asks
whether every floor member is present, and where its entry requires it.

Only the second can see a member dropped from the payload and from its consumers
at once, which is the shape the missing `libsqlite3.so.0` has. Both run; neither
result stands in for the other.

### Version coherence, resolved through the provider the object names

For each static subject and each version need it records, the design resolves the
`DT_VERNEED` provider name through the provider directories in loader order,
selects the first candidate, requires that file to define the needed node, and
requires the resolution to have stayed inside the archive.

ALL FOUR CONDITIONS ARE STATIC, AND THE CHECKER ANSWERS THEM ON EITHER TREE.
An earlier revision said the fourth was the one packaging could not answer. That
was wrong, and round 2 named it: a resolution that leaves the archive is
observable in the file tree, because the checker resolves through the provider
directories itself rather than asking the host. WHAT PACKAGING CANNOT OBSERVE IS
A RUNNING PROCESS FALLING BACK TO THE HOST CACHE, which is the live observer's
subject and nothing else's.

### Duplicate providers, in the loader's terms

For each `DT_NEEDED` name, collect the provider directories in scope order where
a file of that exact name exists, resolve each through its links, and compare
the distinct resolved targets by content digest. Same file from several
directories: one provider. Different content: a refusal, because the loader
picks by directory order and that order is an accident rather than a decision.

THE REFUSAL DOES NOT MAKE SELECTION UNKNOWN. Scope order is deterministic, so
the loader takes the first candidate and so does the checker. Coherence is
evaluated against that selected file, and rule 1 refuses beside it. The two
results are independent, which Design Area 5 states as a rule because round 2
found the previous revision suppressing one with the other.

### Declared family generations, in terms nothing in the file can supply

Two objects with different SONAMEs may be two generations of one family, and no
ELF field says so. The design takes that relationship as declared data and
refuses more generations of a declared family than the declaration permits. An
UNDECLARED family is not checked, which is a deliberate blind spot taken over a
filename heuristic the measurements show would be wrong in both directions.

### Refuse, never prune

No invariant deletes. A packaging step that removes a library on its own
judgement is a worse failure than the one it prevents, so every invariant
refuses and names what it refused, and the repair is a payload or configuration
change made deliberately.

## Design Area 3 for v0.27.0 toolchain-runtime-closure: the configuration and its authority

### Four declarations, one bundle

The declared configuration carries every claim no format supplies: the tool
ROOTS with their declared immediate subdirectories, the FLOOR with its required
location, the FAMILY list with its permitted generation counts, and the active
WAIVERS. They travel together as one document, because a check that read three
of the four would evaluate a contract nobody wrote.

### The bundle has two parts, and only one of them is hashed

| Part | Content | In the digest |
| --- | --- | --- |
| the configuration document | the four declarations, one file | YES, and nothing else is |
| the identity envelope | the document's digest, and the cplx commit that holds it | NO, so the digest never covers itself |

THE DIGEST DOMAIN IS THE CONFIGURATION DOCUMENT'S EXACT COMMITTED BYTES: the
file as cplx stores it, UTF-8, LF line endings, no normalisation, no
canonicalisation pass and no re-serialisation. Hashing bytes rather than parsed
content is what makes the value reproducible by a party that cannot parse the
format.

THE NAMED SOURCE IS A PATH AT A COMMIT SHA. A branch or a tag would let the
named content change under a fixed name, which is the drift this whole area
exists to remove; only a commit SHA is immutable.

### Self-describing is not the same as authoritative

An archive that carries its own configuration answers "what does this archive
claim to owe" and cannot answer "is that what cplx reviewed". A payload and its
embedded contract can be weakened in the same edit and still agree with each
other. That is the paired-edit shape umbrella item 3 met, and shipping the
declaration inside the artifact does not remove it: it hides it, because the two
halves can no longer disagree.

### What each party checks, and what each refuses

| Party | Has cplx access | Resolves the authoritative configuration | Checks | Refuses on |
| --- | --- | --- | --- | --- |
| packaging | yes | reads it at the commit it is about to name | the document it embeds is byte-identical to that source, and the envelope's digest is that document's | mismatch, or a source that is not a committed state |
| verification, Debian agent | no | cannot | the embedded document hashes to the digest its envelope names | absent, substituted or corrupted configuration |
| publication, umbrella item 7 | yes | RESOLVES IT ITSELF, at the release commit being published, independently of anything the archive says | the archive's envelope digest equals the digest of the configuration publication resolved | any difference, and any active waiver |

THE THIRD ROW IS WHERE THE BINDING ACTUALLY LIVES. Round 2 was right that
putting a bundle inside a tar prevents nothing: an authentic bundle can be
swapped for another authentic bundle, and the agent, which can only compare the
document against its own envelope, would accept it.

What closes that is publication NOT TAKING ITS CONFIGURATION FROM THE ARCHIVE.
It resolves the authoritative configuration from cplx at the commit it is
publishing, computes that document's digest, and requires the archive's envelope
to carry the same value. A swapped bundle names a different digest and is
refused; a swapped bundle that names the right digest but carries a different
document is refused by its own internal check.

THE AGENT'S CHECK IS INTERNAL CONSISTENCY, AND THE DESIGN SAYS SO PLAINLY. It
catches substitution or corruption in transit. It cannot catch a paired edit and
it cannot catch an authentic-but-wrong bundle, because catching either needs
cplx. Both are caught by the two parties that have cplx, at packaging and again
at publication.

### The configuration digest is POLICY identity, and never evidence identity

Worth stating because the two look alike and do opposite jobs. The
configuration digest identifies the DECLARATION, and it is deliberately the same
value for every archive built under that declaration: reusability is the point,
since a policy that changed per artifact could not be reviewed once. It
therefore cannot say which archive anything was observed on, and no part of this
design may use it that way. Design Area 7 defines the identity that can.

### The floor entry shape

A floor entry is a lookup name plus a REQUIRED LOCATION. Most require only
presence somewhere in the provider directories, because resolution is what the
floor protects. An entry may constrain a location where physical ownership
matters: `libsqlite3.so.0` is required under `tools/python`, because its consumer
is the interpreter's own extension and a copy living only under another tool's
root would make the python payload depend on that tool's payload.

### The family entry shape

A family entry is a name, a set of SONAME patterns, and a permitted generation
count. The initial list carries `binutils-bfd` and `binutils-opcodes` at one
generation each, which refuses the current archive on the measured libbfd pair.

## Design Area 4 for v0.27.0 toolchain-runtime-closure: waivers and the boundary

### A waiver is an exception with an expiry condition, not a mute

Each waiver names ONE FLOOR MEMBER, the requirement that removes it, and the
observable condition under which it is removed, which is that floor entry's own
test succeeding. This is the issue's contract, unchanged.

AN EARLIER REVISION ADDED A SECOND SUBJECT TYPE, for tool roots, and round 2 was
right to refuse it: this design cannot amend a settled requirement on its own
authority. The unexpected-root refusal of Design Area 1 is therefore unwaivable,
which removes the need for the schema change rather than deferring it. Nothing
is lost, because a root refusal is repairable immediately and is not blocked on
another umbrella item.

### Three failures the waiver model must itself produce

An UNKNOWN waiver, naming nothing the configuration declares, fails. A STALE
waiver, whose removal condition is already satisfied, fails. And an archive
produced while any waiver is active is a VALIDATION ARTIFACT that publication
refuses.

### The publication re-check, in a fixed order

Publication does not read a marker, and it does not trust the archive's copy of
anything. Over the exact archive it is about to publish, in this order:

0. COMPUTE THE ARCHIVE IDENTITY of the file it is about to publish, as Design
   Area 7 defines it;
1. resolve the authoritative configuration from cplx at the release commit, and
   require the archive's envelope digest to equal that document's digest;
2. require a verification result KEYED TO THE IDENTITY COMPUTED IN STEP 0,
   naming that same configuration digest, present and passing;
3. re-run the static checker over this archive against the configuration
   PUBLICATION RESOLVED, not the one the archive carries;
4. refuse if any validated waiver is active, with no mode and no flag that
   permits one.

STEP 1 IS WHY THE ORDER MATTERS. A stripped, weakened or swapped configuration
fails before the waiver question is ever asked, so "no active waivers" is never
returned by an absence.

STEP 0 IS WHY STEP 2 IS A CHECK RATHER THAN A LOOKUP. An earlier revision asked
only that a comparison be "present for THIS archive" and never said what made it
this archive's. Two different things are needed and they are different kinds:
the CONFIGURATION digest identifies reusable policy bytes and is the same across
every archive built under that policy, so it cannot bind evidence to an
artifact; the ARCHIVE identity does, and publication computes it rather than
reading it.

Note what this design does NOT claim: co-location binds nothing, for evidence
any more than for configuration. Re-evaluating THIS archive against the
configuration publication resolved, and requiring a comparison keyed to THIS
archive's bytes, are the two protections, and both are deliberately insensitive
to what traveled beside the file.

### Why the waiver exists at all

The requirement is ordered before the payload it enforces. The alternatives were
to enforce immediately, which makes the declared umbrella order unlandable for
two requirements, or to enforce later, which hands the rule to a requirement that
does not exist yet. The waiver is the third option, and its cost is the machinery
above.

## Design Area 5 for v0.27.0 toolchain-runtime-closure: composition and evidence

### What runs where, stated once

THE STATIC CHECKER RUNS IN BOTH CONTEXTS, and answers all four invariants in
each: on the build account over the tree being packaged, and on the Debian agent
over the installed tree. THE LIVE OBSERVER RUNS ONLY ON THE FOREIGN HOST,
because a process is the only thing that can demonstrate no host fallback.
VERIFICATION COMBINES their typed results into one verdict, and is also the
first actor able to compare the two scope observations.

PACKAGING MAKES NO CLAIM ABOUT RUNTIME HOST FALLBACK. It cannot: only a running
process shows it. Its verdict is explicitly partial, and saying so is what keeps
a green packaging run from reading as a complete answer.

### Two readings, both required to be conclusive

A LISTING over the whole provider set, and a LIVE TRACE that names the process
it inventoried. The second requirement is not ceremony: a trace that inventoried
nothing once reported "no host library loaded", a true sentence about an empty
observation that reads as a pass.

### Aggregation follows data availability, not the presence of another refusal

Every invariant is evaluated; none is skipped; every independent result is
reported. UNDETERMINED means ONE THING ONLY: AN INPUT COULD NOT BE OBTAINED.

| Situation | Result |
| --- | --- |
| a `DT_NEEDED` name resolves nowhere in the observed scope | the name is a REFUSAL, and the version needs recorded against THAT name are UNDETERMINED, because there is no provider file to read |
| a floor member is absent | a REFUSAL. Version needs are affected only where that member is also the unresolved provider of a need, which is the row above |
| one lookup name has candidates of different content | rule 1 REFUSES, and coherence STILL EVALUATES against the first candidate in scope order, because loader selection is deterministic |
| a directory is UNEXPECTED | a REFUSAL, and every local result is still computed and reported, because each host's own observed order is intact |
| the two scope observations DIVERGE | a REFUSAL that blocks the COMBINED verdict, while each host's local results stand as taken |
| a provider file exists but cannot be read | UNDETERMINED for what it would have answered |

THE THIRD ROW IS THE CORRECTION ROUND 2 ASKED FOR. An earlier revision
suppressed coherence whenever rule 1 refused, on the reasoning that provider
selection was unknown. It is not unknown: scope order decides it, the loader
follows it, and so does the checker. Refusing the ambiguity and still answering
the question are both correct, and doing only the first threw away a real
result.

An UNDETERMINED result is neither a pass nor a failure. It is reported with the
input it lacked, and it never counts toward a green.

### Controls, one per independently refusable invariant

The issue's nine, plus the results this design adds: an unexpected directory or
root, a divergent presence comparison at verification, a configuration whose
digest does not match the one publication resolved, and a coherence answer that
survives a rule 1 refusal. One representative failure would leave the rest
unasserted; exhaustive mutation would measure the implementation rather than the
requirement.

A POSITIVE CONTROL SITS BESIDE THEM: the unmodified archive must PASS rule 1.
Twenty needed names have several candidate paths, so a rule 1 that over-refused
would be caught by nothing else.

## Design Area 6 for v0.27.0 toolchain-runtime-closure: the D10 interface

The issue decided D10 as a conditional policy and named umbrella item 7 as the
supplier of its evidence. This design owns the interface between them, which
neither document had defined.

### The evidence item 7 produces

Round 2 refused an earlier version of this table because it described only the
provider that happens to ship, which cannot answer a question about a candidate
that does not. The evidence therefore has two halves: what the archive REQUIRES,
and what each CANDIDATE GENERATION PROVIDES.

| Field | Content |
| --- | --- |
| reading generation | which libstdc++ and libgcc_s generation built the archive this reading was taken from |
| consumer set | every static subject recording a `DT_NEEDED` on `libstdc++.so.6`, taken with THIS DESIGN'S subject rule, that is every shipped ELF |
| required nodes | the `GLIBCXX_` and `CXXABI_` version needs those subjects record, and the `GCC_` needs recorded against `libgcc_s` |
| candidate capabilities | for EACH candidate generation, GCC 11 and GCC 12: its identity, the nodes its `libstdc++` defines, and the nodes its `libgcc_s` defines |

Binding the consumer set to this design's subject rule is deliberate: a D10
reading that walked from entry points would miss the same 76 extension modules
Design Area 2 measures, and would answer the compiler question about a minority
of the archive.

### The result the policy returns

Applied to that evidence, the policy returns THE LOWEST CANDIDATE THAT SATISFIES
EVERY REQUIRED NODE, or a failure:

| Result | Condition |
| --- | --- |
| GCC 11 | the GCC 11 capability entry defines every required `GLIBCXX_`, `CXXABI_` and `GCC_` node |
| GCC 12 | it does not, and the GCC 12 capability entry does |
| NEITHER SATISFIES, packaging fails | neither capability entry does |

ZERO SPARE NODES IS ALLOWED: the condition is satisfaction, not headroom. The
result depends on the CANDIDATE capability entries and never on which generation
the reading happened to be taken with, which is what an earlier version got
wrong: an archive already carrying GCC 12 and satisfying would have been scored
as GCC 11.

### When the reading must be taken again

The required-node set is itself a property of how the archive was built, so a
reading taken under one generation does not automatically describe an archive
built under another. If the returned candidate differs from the reading
generation, item 7 rebuilds with the returned candidate, takes the reading
again, and re-evaluates. THE SECOND EVALUATION MUST RETURN EXACTLY THE SAME
CANDIDATE. EVERY OTHER RESULT IS NON-CONVERGENT AND THE POLICY FAILS: a higher
candidate, a lower one, or neither satisfying. There is no third iteration.

Stating all three is deliberate. A higher second result means the requirement
set grew with the generation, a lower one means the first reading overstated
what the archive needs, and neither satisfying means the rebuild changed the
requirements out of range. All three say the evidence is unstable under the
build it describes, which is a finding to report rather than a search to
continue.

THE EVIDENCE MUST BE CONCLUSIVE ON ITS OWN TERMS. A consumer set of zero is not
a pass: it means the reading found no consumer of `libstdc++.so.6` in an archive
that ships one, which is an empty observation reading as a satisfied condition,
the same failure the live trace already refuses.

## Design Area 7 for v0.27.0 toolchain-runtime-closure: the archive identity

Round 3 accepted the trust boundary and found one contract still open: the
publication step required a comparison to be "present for THIS archive" and
never said what made it this archive's. Co-location binds evidence no better
than it bound configuration, and the configuration digest cannot help, because
it identifies reusable policy rather than bytes.

### The archive identity, and when it exists

THE ARCHIVE IDENTITY IS THE SHA-256 OF THE COMPLETED ARCHIVE FILE'S EXACT BYTES,
computed after the tar is closed and never over an unpacked tree. One value, one
file, recomputable by anyone holding it.

IT DOES NOT EXIST UNTIL PACKAGING HAS FINISHED, which is the ordering fact that
decides the rest of this area. Nothing sealed inside the archive can name it,
including the configuration bundle, so the evidence that carries it must be
EXTERNAL to the archive. That is the same impossibility Design Area 3 met from
the other side, and it is why this design binds by recomputation rather than by
containment.

### What the evidence records

ONE ARTIFACT, produced by verification, keyed by the archive identity:

| Field | Content |
| --- | --- |
| archive identity | the digest of the exact file that was verified |
| configuration digest | the policy the observations were taken under, so a comparison cannot be read against a different declaration |
| pre-install observation | presence per declared candidate directory, derived by verification FROM THE ARCHIVE, before installing |
| installed observation | presence per declared candidate directory, over the installed tree |
| comparison verdict | PASS, or the DIVERGENT entries with the side each was seen on |
| unexpected findings | any observed loader directory absent from the declared shape, per side |

There is no transported packaging artifact. Packaging observes locally and
refuses UNEXPECTED early, and that verdict never leaves the build account,
because verification derives the build-side half itself.

### Why verification derives the build-side half rather than receiving it

Round 3 offered both routes and this design takes the second, for a reason
beyond cost. THE COMPARISON THAT MATTERS IS ARCHIVE AGAINST INSTALLED TREE, not
build account against installed tree: a directory that existed where the tar was
made but never entered the tar is exactly the gap this requirement exists to
catch, and a retained build-account claim would report it as present on both
sides.

Deriving it also removes a claim that would otherwise have to be trusted and
bound. One fewer transported artifact is one fewer thing that can arrive
authentic and belong to something else.

### How publication proves the evidence is this archive's

Publication holds the file it is about to publish. It computes that file's
identity itself, and requires a verification result whose `archive identity`
field is that value and whose `configuration digest` field is the digest of the
configuration publication resolved from cplx.

TWO FAILURES FALL OUT OF THIS RATHER THAN NEEDING SEPARATE RULES. A valid result
from another archive names a different identity and is refused. An archive
altered after verification hashes differently, so no result names it and it is
refused. Neither refusal depends on where the evidence was stored or on what
traveled beside the file.

### What this area does not do

It does not authenticate the evidence against tampering by a party that can
write both the archive and the result. A holder of both could produce a
consistent pair. What it establishes is that the evidence describes THESE BYTES,
which is the property step 2 of the publication order needs and the one round 3
found missing. Publication also re-runs the static checker itself in step 3,
which is independent static assurance and not a re-derivation of the
verification result:
it neither authenticates nor reproduces the verification-only cross-root
comparison and the live observation. The provenance of that verification result
stays an operational trust assumption, outside what the archive-identity binding
establishes.

## Acceptance Cases for v0.27.0 toolchain-runtime-closure

### Membership, coherence, duplication and families

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| a floor member absent from the scope, unwaived | packaging refuses, naming the member | the declared half exists for exactly this |
| `libsqlite3.so.0` present only under `tools/git` | packaging refuses on the location constraint | its entry requires `tools/python` |
| the same, with the sqlite waiver active | archive produced, marked as a validation artifact, publication refused | the ordered transition the waiver exists for |
| a waiver whose member is now present | packaging refuses the waiver as stale | a dead exception must not outlive its cause |
| a `DT_NEEDED` name resolving nowhere in the observed scope | packaging refuses | the derived half |
| a version need whose selected provider does not define it | packaging refuses, naming need, provider and scope | provider-aware coherence |
| a resolution that leaves the archive | the STATIC checker refuses, in either context | all four coherence conditions are static |
| a dependency the archive resolves, loaded from the host cache at run time | the Debian LIVE OBSERVER refuses | the one condition no static read can answer |
| two candidate paths for one lookup name, different content | packaging refuses, naming both paths and digests | rule 1 |
| twenty lookup names with several candidate paths, all one file | packaging ACCEPTS | rule 1 must not over-refuse, and the current archive is this case |
| `libbfd` at two generations, family declared | packaging refuses | rule 2 on the measured pair |
| the same, family undeclared | not examined | the declared blind spot, taken over a heuristic |

### Subjects, and what the entry-point walk would have missed

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| a `lib-dynload` extension module with an unresolvable `DT_NEEDED`, reached by no entry-point walk | packaging refuses, naming the module | the measured 76-module gap; a walk-based subject set would report a pass |
| a `site-packages` wheel extension with a version need its provider does not define | packaging refuses | the pymupdf class, and 28 of these ship today |
| a shipped ELF that no entry point and no `DT_NEEDED` edge reaches, otherwise sound | ACCEPTED, and reported as unreferenced | unreferenced is a finding, never an exclusion |
| a second `libssl.so.3` under `root/usr/bin` | examined as a SUBJECT, never counted as a PROVIDER | it is shipped, so its needs must resolve; `build_elf_rpath` never adds that directory, so nothing resolves through it |

### Scope: declared shape, observed loader scope, and the comparison

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| a declared candidate directory absent under both roots | ACCEPTED, reported as absent | a tool root legitimately has no `root/lib`, and the loader skips it |
| an observed immediate subdirectory under a declared root that the declaration does not list | packaging refuses as UNEXPECTED, naming it | subdirectories are declared, not discovered |
| `tools/old/py3.13` present and not declared | packaging refuses as an unexpected root, naming it | the measured root |
| the same, with a waiver attempting to name the root | the waiver is refused as UNKNOWN | waivers name floor members only, and this design does not amend that |
| a floor member present ONLY under an undeclared root | packaging refuses on the unexpected root, and the member is still resolvable in the observed scope | the loader would find it, so the refusal is what stops it counting |
| a directory PRESENT in the archive and ABSENT under the installed tree | packaging PASSES its local check, and VERIFICATION refuses DIVERGENT | packaging cannot observe a tree that does not exist yet |
| a directory present on the build account that never entered the tar | packaging PASSES, and VERIFICATION refuses DIVERGENT | the comparison is archive against installed tree, which is why the build-side half is derived from the archive |
| `tools/python/current/lib` and `tools/python/python-3.13.9/lib` both declared, resolving to one file | ACCEPTED, one provider | an alias is a declared subdirectory, and rule 1 must not refuse two paths to one file |
| an immediate subdirectory present under a declared root but absent from that root's declared list | packaging refuses as UNEXPECTED | the installer loop adds every subdirectory, so the declaration must too |
| verification unable to read the pre-install archive contents | verification refuses, naming the missing input | the comparison is required, not opportunistic |
| publication given an archive whose divergence comparison never ran | publication refuses | step 2 of the publication order |

### Configuration authority

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| the embedded document does not hash to the digest its envelope names | every host refuses, before any invariant runs | substitution or corruption in transit |
| the bundle carries no configuration at all | every host refuses | absence is not a pass |
| the envelope names a branch or a tag rather than a commit SHA | packaging refuses to produce it | only a commit SHA is immutable |
| a floor entry deleted in the same edit that removes the payload, and the document re-hashed to match its own envelope | the Debian agent ACCEPTS, and packaging and publication both refuse | the paired edit, caught only where cplx is visible, and the agent's limit stated rather than hidden |
| the bundle replaced with a different, internally consistent, authentic bundle | the Debian agent ACCEPTS it, and publication refuses on the digest it resolved itself | co-location binds nothing; publication's own resolution does |
| the named cplx commit does not hold that configuration at that path | packaging and publication refuse | the source is a path at a commit, and both parties can read it |

### Evidence identity

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| a valid, passing verification result for archive A, supplied with archive B | publication refuses | the result names A's identity, and publication computes B's |
| the candidate archive is modified after verification, evidence unchanged | publication refuses | the recomputed identity matches no result |
| a verification result whose configuration digest differs from the one publication resolved | publication refuses | the comparison was taken under a different declaration |
| two archives built under the same configuration, each with its own result | each publishes against its own | policy identity is shared by design; archive identity is not |
| a verification result present, passing, and keyed to the exact archive | publication proceeds to step 3 | the property step 2 needs, and the only one it asserts |

### Aggregation

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| a `DT_NEEDED` name resolves nowhere, and version needs are recorded against that name | the name is a REFUSAL; those needs are UNDETERMINED, naming the unresolved provider | there is no file to read |
| one lookup name with two candidates of different content, and version needs answered by that name | rule 1 REFUSES, and coherence is EVALUATED against the first candidate in scope order and reported | loader selection is deterministic, so the answer exists |
| a floor member absent, and unrelated version needs elsewhere | the member is a REFUSAL; the unrelated needs are evaluated normally | floor absence suppresses nothing by itself |
| an UNEXPECTED directory on one host | a REFUSAL, and every local result on that host is still computed and reported | the host's own observed order is intact |
| the two observations DIVERGE | the combined verdict is refused, and each host's local results stand as taken | divergence is a property of the pair, not of either reading |
| an UNDETERMINED result and no refusal anywhere | NOT a pass | an undetermined answer never counts toward a green |
| a live trace that inventoried no process | reported inconclusive, never as a pass | the develop#20 failure, refused by construction |

### The D10 interface

| Scenario | Expected outcome | Reason |
| --- | --- | --- |
| the GCC 11 capability entry defines every required node | the policy returns GCC 11 | the lowest satisfying candidate, zero spare nodes required |
| it does not, and the GCC 12 entry does | the policy returns GCC 12, item 7 rebuilds with it and re-reads | the candidate differs from the reading generation |
| that second reading returns GCC 12 again | the policy is settled at GCC 12 | the convergence the re-read exists to establish |
| that second reading returns a HIGHER candidate | packaging fails as non-convergent | the requirement set grew with the generation |
| that second reading returns a LOWER candidate | packaging fails as non-convergent | the first reading overstated what the archive needs, and there is no third iteration |
| that second reading satisfies NEITHER candidate | packaging fails as non-convergent | the rebuild moved the requirements out of range |
| the reading was taken under GCC 12, and GCC 11 satisfies the required nodes | the policy returns GCC 11 | the result follows the candidate capabilities, never the shipped generation |
| a required node that neither capability entry defines | packaging fails | the third result, which an earlier reading of D10 left out |
| the reading finds zero consumers of `libstdc++.so.6` in an archive that ships one | reported inconclusive, never as a satisfied condition | an empty observation reading as a pass, refused as everywhere else |

## Open questions for the v0.27.0 toolchain-runtime-closure design

### Q01: what the candidate shape is derived FROM, and who may compare two of them

Question description: the design requires packaging and verification to evaluate
the same scope. Round 1 showed that one shared function is not enough when it
enumerates by testing what exists. Round 2 showed that the round 2 answer was
still not enough, for two separate reasons: the version directories under each
root also come from a glob, so a root list alone cannot produce the candidate
set; and DIVERGENT was assigned to packaging, which runs before the installed
tree exists and cannot observe it.

#### BBQ for Q01

Two surveyors must mark the same boundary. One reads the deed each time. One
copies the other's pegs. One reads the deed but only marks corners where a fence
already stands. And one reads a deed that names the plot but not the lots inside
it, then fills in the lots by walking the ground, which is the fourth surveyor
believing they read everything from the deed.

There is also a question of who may declare a discrepancy: the surveyor who has
seen one plot cannot report that two plots differ.

In this picture: the deed is the declared configuration, the lots are the
version directories, the fences are the directories that happen to exist, and
the discrepancy is DIVERGENT.

#### Options for Q01

- Option A1: ONE SHARED DERIVATION, both callers invoke the same existence-testing
  code.
  - pro: a change to the directory set is one edit.
  - con: refused in round 1. The set is still empirical, so two roots give two
    lists from one call.
- Option A2: THE INSTALLER EMITS THE SHAPE, packaging reads that artifact.
  - pro: one producer, and the artifact is inspectable evidence.
  - con: packaging precedes installation, so the artifact describes another
    tree.
- Option A3: A WRITTEN SPEC BOTH IMPLEMENT, with a conformance case.
  - pro: neither side depends on the other's code.
  - con: two implementations that agree only while the conformance case runs.
- Option A4: A DECLARED CANDIDATE SHAPE FROM THE DECLARED ROOTS, plus a separate
  observation step, with DIVERGENT refused by whichever context finds it.
  - pro: the shape stops being empirical.
  - con: refused in round 2, twice over. `build_elf_rpath` globs
    `$tool_dir/*/` for version directories, so roots alone underdetermine the
    shape; and packaging cannot refuse DIVERGENT, having seen one tree.
- Option A5: A4 WITH THE LAYOUT FULLY DECLARED AND THE COMPARISON RETIMED. The
  declared shape is the product of declared ROOTS, THE DECLARED IMMEDIATE
  SUBDIRECTORIES of each root, and this design's fixed relative suffixes, so no
  filesystem is consulted to build it. The subdirectory list is not a version
  list: the installer loop adds every immediate subdirectory, and the measured
  python root contributes `current`, an alias, beside `python-3.13.9`.
  Separately, the OBSERVED LOADER SCOPE is what `build_elf_rpath` produces over
  the real tree, and resolution uses it, so the check reads what the loader
  reads. Anything in the observed scope that the declared shape lacks, an
  undeclared root or an undeclared subdirectory, is UNEXPECTED and refuses
  locally. Packaging observes its tree and refuses UNEXPECTED, and that
  observation stays local; VERIFICATION derives BOTH sides, one from the archive
  before installing and one from the installed tree, compares them, and refuses
  DIVERGENT; PUBLICATION requires that comparison, keyed to the archive identity
  of Design Area 7 and Q09.
  - pro: every candidate directory is derivable from the declaration alone,
    which is what "root-independent" has to mean if it means anything.
  - pro: each result is refused by an actor that can observe it.
  - pro: declaring the subdirectories makes a new interpreter version, or a new
    alias, a deliberate configuration edit rather than something the tree
    acquires.
  - pro: nothing about the comparison is transported, so nothing about it has to
    be bound to the archive except its single result.
  - con: the configuration grows a per-root subdirectory list that must be kept
    current, and forgetting to update it refuses the build.
  - con: two scopes to keep straight, declared and observed, rather than one.

#### Recommended option for Q01 (with arguments for this choice)

Option A5. A4 was the round 2 answer and round 2 refuted both of its halves with
the source in hand: the version-directory glob is at
`src/setups/env/bin/install_pkg.sh:894`, and packaging genuinely cannot see the
installed tree.

The second con is the honest cost and it is worth paying. A declared version
list is exactly the kind of claim this requirement exists to make explicit: the
alternative is that the archive's search scope changes because a directory
appeared, which is the class of silent change the whole document is about.

#### Answer to Q01: option A5 (with reason why it must be accepted as the answer)

Option A5. It is the only option where "packaging and verification evaluate the
same scope" is derivable rather than observed, and the only one where each typed
result is produced by an actor that can actually observe it.

Round 3 accepted A5 subject to two things this text now carries. The declaration
is a SUBDIRECTORY list, so an alias such as `current` is declared rather than
refused; the measurement shows `current/lib` and `python-3.13.9/lib` both on the
rpath, reaching one file. And the comparison no longer rests on a transported
packaging claim: verification derives both sides from what it holds, which
removes an artifact that would otherwise need binding and makes the comparison
ask the more useful question, archive against installed tree.

### Q02: what the `old/` tool root is, and what happens to it now

Question description: the measured scope contains ten directories across THREE
tool roots, and one of them is `tools/old/py3.13`. Every relocated ELF carries
that directory on its rpath. Round 1 asked for a completed decision. Round 2
accepted the direction and found two inconsistencies: the answer said the
candidate shape comes only from declared roots while also saying every observed
root stays in loader scope, and it introduced a root waiver into a waiver
contract the issue settled over floor members.

#### BBQ for Q02

A kitchen's mise en place includes a shelf of last season's ingredients that
nobody removed. An inventory that counts the shelf says the kitchen is stocked.
An inventory that ignores it says the kitchen is short. An inventory that flags
the shelf says what is actually wrong, and it still has to admit that the cooks
can reach the shelf, because they can.

In this picture: the shelf is `tools/old/py3.13`, reaching it is the loader
resolving there, and flagging is the refusal.

#### Options for Q02

- Option B1: TREAT EVERY `tools/*/` ROOT AS SCOPE, including `old/`.
  - pro: matches `build_elf_rpath` exactly.
  - con: a member present ONLY under `old/` satisfies the floor.
- Option B2: EXCLUDE NON-CURRENT ROOTS from the scope the invariants read.
  - pro: describes the intended payload.
  - con: diverges from the loader, which is the error class this design refuses.
- Option B3: SCOPE FOLLOWS THE LOADER, AND AN UNEXPECTED ROOT IS ITS OWN
  FINDING, severity unstated.
  - con: refused in round 1. A finding whose consequence is unstated is a note.
- Option B4: B3 COMPLETED, WITH A ROOT WAIVER. Declared roots, an unexpected
  root refuses, and the refusal is waivable by a waiver whose subject is a root.
  - con: refused in round 2. It amends the issue's waiver schema on this
    design's own authority, and it left the two scopes ambiguous.
- Option B5: TWO SCOPES, STATED SEPARATELY, AND AN UNWAIVABLE REFUSAL. The
  DECLARED candidate shape contains declared roots only. The OBSERVED LOADER
  SCOPE contains every root the loader finds, `old/` included, and resolution
  runs against it, so the check never pretends a directory the loader searches
  is invisible. Every observed element absent from the declared shape is
  UNEXPECTED and packaging REFUSES. The refusal is NOT waivable, and the issue's
  waiver contract is left exactly as it was settled.
  - pro: the two sentences round 2 called contradictory are now two different
    scopes, each with a name and a use.
  - pro: no requirement amendment is needed, so no cross-document authority
    question arises.
  - pro: the refusal is repairable on the spot, by removing the root or
    declaring it, and neither repair waits on another umbrella item, so a waiver
    would buy nothing.
  - con: `tools/old/py3.13` must be dealt with before this design's check can
    pass, with no temporary permission available.

#### Recommended option for Q02 (with arguments for this choice)

Option B5. Round 2's two objections have one answer between them. Naming the
observed loader scope separately removes the contradiction, because "resolution
sees `old/`" and "the declared shape does not contain `old/`" are then
statements about different sets, and both are true.

Dropping the waiver is the right side of the second objection. A waiver exists
to buy an ORDERED TRANSITION when a repair is owned by a later item, which is
the sqlite case exactly. An undeclared root has no such dependency: the repair
is a directory removal or a one-line declaration, available immediately. Adding
a schema type to a settled requirement to permit something nobody needs to
postpone is the wrong trade, and this design has no authority to make it.

#### Answer to Q02: option B5 (with reason why it must be accepted as the answer)

Option B5. It settles the measured root, keeps check and loader identical where
that matters, and leaves the issue's waiver contract untouched. The cost, that
`old/py3.13` must be removed or declared before a green run, is a bill this
design should present rather than defer: the root sits on the rpath of every
shipped object, and nothing else in the document would ever mention it again.

### Q03: one mechanism run twice, or a packaging gate and a separate verifier

Question description: the design says the same four invariants run in both
contexts, and also that verification adds a live trace and the no-host-fallback
condition, which packaging cannot evaluate. Whether that is one mechanism with
two modes or two mechanisms sharing a rule set is a structural choice the design
has not made.

#### BBQ for Q03

An aircraft is checked on the ground and again in flight. One organisation can
own both checklists, with the in-flight items simply unavailable on the ground.
Two organisations can own one each. The first cannot let the two drift; the
second cannot stop them.

In this picture: the ground check is packaging, the flight check is the Debian
verification, and the shared items are the four invariants.

#### Options for Q03

- Option C1: ONE MECHANISM, TWO MODES. A packaging mode and a verification mode
  over one rule set, the extra conditions available only in the second.
  - pro: the invariants cannot drift between the two contexts.
  - pro: the same refusal wording appears wherever a rule fires.
  - con: one artifact must run in two quite different environments, one of them
    a CI container with no cplx history.
- Option C2: TWO MECHANISMS sharing declared configuration only.
  - pro: each is simple and suited to its host.
  - con: the four invariants exist twice, and this collection has already been
    burned by two things that agreed until they did not.
- Option C3: ONE MECHANISM FOR THE INVARIANTS, a separate observer for the live
  trace, with verification composing them.
  - pro: the trace is a genuinely different kind of measurement, a running
    process rather than a file tree, and it does not belong in a static checker.
  - pro: the invariants still exist once.
  - con: verification becomes two artifacts whose results must be combined into
    one verdict.

#### Recommended option for Q03 (with arguments for this choice)

Option C3. The four invariants are all static reads of a tree and belong
together; the live trace is not, and folding a process observer into a tree
checker would make one artifact answer two unrelated questions. C2 is refused
for the reason the previous requirement in this collection had to learn twice:
two implementations of one rule agree until nobody is watching.

#### Answer to Q03: option C3 (with reason why it must be accepted as the answer)

Option C3. It keeps exactly one definition of each invariant while letting the
trace be what it is. The composition cost is a verdict that must combine two
results, which the acceptance model already requires anyway, since it demands
both readings be conclusive.

#### The boundary of C3, as round 1 asked for it

The round 1 answer left one thing loose, and the design text repeated it: the
no-host-fallback condition was described in places as though packaging could
observe it. It cannot. The boundary is:

| Owner | Runs where | Answers |
| --- | --- | --- |
| the static checker | build account AND Debian agent | the four archive invariants, over the declared shape observed against that root |
| the live observer | the foreign host only | which process was inventoried, and whether it loaded anything outside the archive |
| verification | the Debian agent | combines the two typed results into one verdict |
| packaging | build account | the static half only, and says so |

PACKAGING'S VERDICT IS EXPLICITLY PARTIAL. Its own host cache answers for
anything that escapes the archive, so it has no way to distinguish a dependency
the archive satisfies from one the host quietly satisfied for it. Target
Behavior and Design Area 5 both state it in these terms now.

#### One stale statement removed, as round 2 asked

Round 2 accepted C3 and found one place where the document still contradicted
it. Design Area 2 said the fourth version-coherence condition, that no step of a
resolution leaves the archive, was the one packaging could not answer. That is
wrong: the static checker resolves through the provider directories itself, so
it answers all four conditions on either tree. WHAT PACKAGING CANNOT OBSERVE IS
A RUNNING PROCESS FALLING BACK TO THE HOST CACHE, which belongs to the live
observer alone. Design Area 2 now says that instead.

### Q04: how the configuration travels, AND what makes it authoritative

Question description: the roots, the floor, the family list and the waivers are
committed in cplx. The verification host is the Debian CI agent, which holds no
cplx history and no credentials for it. Round 1 established that transport and
authority are two problems. Round 2 accepted the three-party model and refused
the binding claim and the undefined digest: putting a bundle inside a tar does
not stop an authentic bundle from being paired with another archive, and the
design never said which bytes are hashed, how the digest avoids covering itself,
which path is read, or which cplx reference is authoritative.

#### BBQ for Q04

An inspector arrives at a site with no access to head office. The standard can
travel with the inspector, travel with the goods, or be quoted from memory. A
standard that travels with the goods is always A standard for those goods, and
is also whatever the shipper put in the box. What settles it is head office
looking up the standard ITSELF when the goods arrive, rather than reading the
copy in the box.

In this picture: head office is cplx, the inspector is the CI agent, the goods
are the archive, the copy in the box is the bundle, and head office looking it
up is publication resolving the configuration at the release commit.

#### Options for Q04

- Option D1: THE CONFIGURATION TRAVELS WITH THE PIPELINE, as a copy landed
  beside the probe.
  - con: the copy can drift and the agent cannot tell. Neither problem closed.
- Option D2: THE CONFIGURATION TRAVELS IN THE ARCHIVE, and is trusted because it
  is there.
  - con: refused in round 1. Self-describing is not authoritative.
- Option D3: A COPY BESIDE THE PROBE PLUS AN IDENTITY MANIFEST, compared
  cplx-side.
  - con: the configuration is beside the archive rather than resolved
    independently, so an authentic copy can accompany the wrong archive.
- Option D4: THE BUNDLE TRAVELS IN THE ARCHIVE AND CARRIES ITS CPLX IDENTITY,
  with co-location claimed as the binding.
  - con: refused in round 2. Co-location binds nothing, and the digest domain,
    the self-reference, the source path and the authoritative reference were all
    undefined.
- Option D5: D4 WITH THE DIGEST DEFINED AND THE BINDING MOVED TO PUBLICATION'S
  OWN RESOLUTION. The bundle is two parts: the CONFIGURATION DOCUMENT, one file
  holding all four declarations, and an IDENTITY ENVELOPE naming that document's
  digest and the cplx COMMIT SHA that holds it. The digest covers the document's
  exact committed bytes and nothing else, so the envelope is never inside its
  own digest. The source is a PATH AT A COMMIT SHA, never a branch or a tag.
  Packaging verifies cplx-side that what it embeds is that commit's bytes.
  Verification, with no cplx access, verifies only that the document hashes to
  the envelope's digest, and the design states plainly that this is internal
  consistency. PUBLICATION RESOLVES THE AUTHORITATIVE CONFIGURATION ITSELF, at
  the release commit it is publishing, and requires the archive's envelope to
  carry that document's digest.
  - pro: every question round 2 asked has a stated answer: which bytes, no
    self-reference, which path, which reference, and who binds.
  - pro: the binding is real without hashing the archive into the configuration
    or the configuration into the archive, which is impossible in that order
    anyway, since the bundle is inside the tar.
  - pro: a swapped authentic bundle is caught, not because it traveled apart
    from the archive but because publication never asked the archive what the
    standard was.
  - con: publication must have cplx access and must know which commit it is
    publishing. That is item 7's own release commit, so it is available, but it
    is a stated dependency.
  - con: the agent's verdict is weaker than it looks, and the design has to keep
    saying so rather than letting "verified" stand unqualified.

#### Recommended option for Q04 (with arguments for this choice)

Option D5. Round 2's objection to D4 was precise and correct: "being inside the
tar does not itself prevent an authentic bundle from being paired with another
archive". The reviewer offered two exits, binding the identity to the archive or
dropping the claim and relying on re-evaluation. D5 takes the second, because
the first cannot be done in the order the artifacts are produced: the bundle is
sealed into the tar before the tar has a digest.

What makes the second exit sufficient is that publication stops treating the
archive as a source of truth about its own contract. It reads cplx.

#### Answer to Q04: option D5 (with reason why it must be accepted as the answer)

Option D5. It answers each of the four undefined items concretely, and it
replaces a claim the design could not support with a mechanism it can. The
limitation it keeps, that the Debian agent checks consistency and not authority,
is stated in Design Area 3 in those words, because a check whose strength is
overstated is worse than one whose limits are written down.

### Q05: how the publication boundary refuses a validation artifact

Question description: an archive produced while any waiver is active cannot
cross the publication boundary, and the refusal is meant to be mechanical.
Publication belongs to umbrella item 7. Round 1 accepted re-evaluation and
demanded a closed input contract. Round 2 accepted the sequence and made it
contingent on Q04: exact-pair language is only as good as the binding behind it,
and there was none.

#### BBQ for Q05

A crate leaves the plant under a conditional pass. The dock can read a tag, keep
a register, or re-inspect. Re-inspection is right, and only if the dock inspects
against ITS OWN copy of the specification. A dock that re-inspects against the
paperwork in the crate has automated reading the crate's own opinion of itself.

In this picture: the crate is the archive, the dock is item 7, the paperwork is
the bundle, and the dock's own copy is cplx at the release commit.

#### Options for Q05

- Option E1: A MARKER INSIDE THE ARCHIVE, written by packaging.
  - con: delivered with the payload, and removable in one edit.
- Option E2: A MARKER BESIDE THE ARCHIVE, in publication metadata.
  - con: two files that can be separated silently.
- Option E3: PUBLICATION RE-EVALUATES THE INVARIANTS and refuses on any active
  waiver it finds.
  - con: refused in round 1. The input is open: strip the configuration and it
    finds none.
- Option E4: E3 OVER THE EXACT ARCHIVE AND THE BUNDLE THAT ARCHIVE CARRIES,
  identity first.
  - con: refused in round 2 through Q04. "The bundle that archive carries" is
    not a binding, so the pair it fixes is not fixed.
- Option E5: E4 EVALUATED AGAINST THE CONFIGURATION PUBLICATION RESOLVES, in a
  fixed order. Over the exact archive being published: resolve the authoritative
  configuration from cplx at the release commit and require the archive's
  envelope digest to equal it; require the verification comparison to be present
  for THIS archive and to have passed; re-run the static checker against THE
  RESOLVED CONFIGURATION, not the embedded one; refuse if any validated waiver
  is active, with no mode and no flag that permits one.
  - pro: the input is closed by publication's own resolution rather than by a
    property the archive was asserted to have.
  - pro: every route to a publish passes a refusal that cannot be reached by
    removing something: an absent or swapped configuration fails step 1, and a
    missing comparison fails step 2.
  - con: "present for THIS archive" names no identity. Round 3 found it: the
    configuration digest identifies reusable policy, so it cannot say which
    archive a comparison belongs to, and a valid result from another archive
    would satisfy the step as written. Q09 supplies the missing identity, and
    E5 is correct once it does.
  - con: publication now depends on this requirement's mechanism, on cplx
    access, and on an artifact produced by an earlier actor. Three couplings
    between items 4 and 7, all explicit.

#### Recommended option for Q05 (with arguments for this choice)

Option E5. The mechanism has been right since E3 and the input has been wrong
twice. Round 2's phrasing is the cleanest statement of the fix: re-evaluation,
not co-location, validates the pair. Making that literal means naming what
publication reads, and the answer is cplx.

The order is still the load-bearing part. Identity first means there is no path
where "no active waivers" is returned by an absence rather than by a check, and
step 2 means there is no path where an unverified archive is published because
nobody looked for the verification.

#### Answer to Q05: option E5 (with reason why it must be accepted as the answer)

Option E5, WITH STEP 2 KEYED BY Q09'S ARCHIVE IDENTITY. The order and the
resolution are right and round 3 confirmed both. What was missing was an
identity for the evidence, and it is supplied rather than assumed: publication
computes the archive's digest itself and requires a verification result naming
that value and the configuration digest it resolved. The step then reads
"present for THIS archive" and means it.

It is the version of the boundary where each step names an input that some party
can independently obtain, and where nothing the archive says about itself is
load-bearing. The couplings to item 7 are the contract doing work rather than a
dependency to regret, and they are listed rather than implied.

### Q06: what the subject set of the derived closure is

Question description: the derived half asks whether every `DT_NEEDED` of every
shipped object resolves inside the scope. The archive ships ELF objects that are
NOT in a provider directory, `root/usr/bin/libssl.so.3` among them, and ships
many that no static edge reaches at all. Round 1 refused the round 1 answer as
incorrect rather than incomplete, and the refusal was measurable, so it was
measured.

#### BBQ for Q06

A warehouse inventory can cover everything on the premises, everything on the
picking shelves, or everything reachable from the loading bay by following
requisitions. The third sounds the most principled until you notice that the
night shift takes crates straight off the floor without ever writing a
requisition, and that most of the stock moves that way.

In this picture: the premises are the whole archive, the picking shelves are the
provider directories, the requisitions are `DT_NEEDED` edges, and the night
shift is CPython importing an extension module by path.

#### Options for Q06

- Option F1: EVERY SHIPPED ELF is a subject, in a provider directory or not.
  - pro: nothing shipped escapes examination.
  - con: an object outside the provider directories resolves through a search
    list it will never use, unless the design says otherwise.
- Option F2: ONLY OBJECTS INSIDE THE PROVIDER DIRECTORIES are subjects.
  - pro: every subject is examined under the search list that applies to it.
  - con: an executable under `root/usr/bin` is a real thing the archive ships
    and runs, and this would never look at it.
- Option F3: SUBJECTS ARE THE TRANSITIVE CLOSURE FROM THE ENTRY POINTS, the
  interpreter and the shipped executables, followed through `DT_NEEDED`.
  - pro: examines what a static walk can reach.
  - con: MEASURED AND REFUTED.
    [measurements.closure-subjects.rhel.txt](measurements.closure-subjects.rhel.txt)
    walks it from 185 entry points, generously, and misses 395 of 628 shipped
    ELFs, among them 76 `lib-dynload` extension modules and 28 under
    `site-packages`, with no shipped object naming any of them. The extension
    modules are `dlopen`ed by path at import time, so no `DT_NEEDED` walk can
    ever reach them.
  - con: the objects it misses are exactly the class that motivated this work.
    The pymupdf and manylinux wheel failures live entirely inside the gap, so
    F3 would have produced a green verdict on the archive that broke.
- Option F4: FOUR SETS, KEPT APART. PROVIDER DIRECTORIES are where a lookup may
  find a candidate. STATIC SUBJECTS are every ELF the archive ships, however it
  is loaded. RUNTIME ENTRY POINTS are declared, and are where execution can
  begin. LIVE OBSERVATIONS are what one real process loaded, on the foreign host
  only. Every static subject's recorded dependencies must resolve through the
  provider directories; an object that no entry point and no `DT_NEEDED` edge
  reaches is reported as UNREFERENCED and is still checked.
  - pro: the `dlopen` class is covered by construction, because membership in
    the subject set does not depend on reachability at all.
  - pro: it separates the two things F1 and F2 each collapsed: being a subject
    and being a provider are different roles, and `root/usr/bin/libssl.so.3` is
    the first and not the second.
  - pro: "the archive ships something nothing can load" becomes a reported
    result instead of a silent exclusion.
  - con: more subjects to examine, and one more declared list, the entry points,
    which is used by the live observer rather than by the static checker.

#### Recommended option for Q06 (with arguments for this choice)

Option F4. F3 was the round 1 answer and it is wrong on the evidence: the word
CLOSURE suggested entry points, and the archive's actual loading behaviour does
not go through them. Round 1 said so before the measurement existed, and the
measurement confirms it at 76 extension modules and 0 declaring edges.

F1 is the correct subject set and, taken alone, invites the objection that an
object outside the provider directories would be judged against a search list it
never uses. F4 is F1 with that objection answered structurally: the subject set
and the provider set are different sets, so a shipped object is examined for
what IT needs while never being counted as a place where anything else may find
something.

#### Answer to Q06: option F4 (with reason why it must be accepted as the answer)

Option F4. A guarantee that cannot see the objects whose failures produced the
requirement is not the guarantee that was asked for. Reachability may describe a
finding, unreferenced, but it must never decide membership, because the loading
mechanism that matters here leaves no static trace to follow.

#### Round 2 accepted F4 without further change

The four sets now separate subjects from providers, and the retained measurement
supports every-shipped-ELF coverage directly. No structural change was requested
and none is made. The one adjustment elsewhere that touches this answer is
Design Area 6, where the D10 consumer set is bound to the SAME subject rule, so
the compiler question is asked about the whole archive rather than about
whatever a walk could reach.

### Q07: what a refusal reports, and when a result is genuinely unavailable

Question description: every invariant refuses and names what it refused. The
question is what happens to a result whose input another result touched. Round 1
refused a fixed invariant order, on the ground that duplication decides which
provider coherence examines. Round 2 refused the replacement for the opposite
reason: it suppressed too much. A duplicate-provider refusal does not make
selection unknown, because scope order is deterministic, and a floor absence
does not make unrelated coherence unanswerable.

#### BBQ for Q07

A compiler can stop at the first error or list them all. The good ones do
something more: after an unknown type, they do not report every use of it as a
separate fault. But they also do not stop reporting everything else, and they
certainly do not refuse to type-check an expression whose operands they can read
perfectly well just because something nearby was wrong.

In this picture: the unknown type is a provider that resolves nowhere, and the
expression they can still read is a lookup name whose candidates are ambiguous
but whose selection is still decided by order.

#### Options for Q07

- Option G1: FAIL FAST at the first refusal.
  - con: one packaging round per gap, and packaging a full tree is not cheap.
- Option G2: COMPLETE INVENTORY, every refusal a peer of every other.
  - con: consequences read as independent faults.
- Option G3: COMPLETE INVENTORY WITH A FIXED ORDER, membership then coherence
  then duplication.
  - con: refused in round 1. Duplication can decide what coherence examines, so
    the order is not universally safe.
- Option G4: COMPLETE INVENTORY WITH SUPPRESSION DRIVEN BY OTHER REFUSALS. Any
  result whose input another result touched becomes UNDETERMINED.
  - con: refused in round 2. It suppressed answers that exist: coherence under a
    rule 1 refusal is computable, since scope order selects deterministically,
    and floor absence only matters where the absent member IS the unresolved
    provider.
- Option G5: COMPLETE INVENTORY WITH SUPPRESSION DRIVEN BY DATA AVAILABILITY.
  UNDETERMINED means exactly one thing: AN INPUT COULD NOT BE OBTAINED. A
  `DT_NEEDED` name that resolves nowhere makes the version needs against THAT
  name undetermined, because there is no file to read; a provider that exists
  but cannot be read does the same. Everything else is reported. A rule 1
  refusal stands beside a coherence answer taken against the first candidate in
  scope order. A floor absence is a refusal and suppresses nothing by itself. An
  UNEXPECTED directory is a refusal and every local result is still computed. A
  DIVERGENT comparison blocks the COMBINED verdict while each host's local
  results stand as taken.
  - pro: the rule is one sentence and it is checkable: did the check have the
    bytes it needed.
  - pro: deterministic loader selection is preserved rather than contradicted,
    which matters because the rest of the design leans on it.
  - pro: local and combined verdicts are separated, which is what lets a
    two-host model report a cross-host problem without discarding two valid
    single-host readings.
  - con: three result types, and every consumer of the report handles the third.
  - con: a report can now carry a refusal AND a normal answer about the same
    lookup name, which reads oddly until you know why.

#### Recommended option for Q07 (with arguments for this choice)

Option G5. Round 2's correction is precise and it is a fact about this design
rather than a preference: the duplicate-provider rule exists BECAUSE selection
is by order, so the selected file is known even while the ambiguity is refused.
Suppressing coherence there discarded a real answer and, worse, made the
suppression rule sound like it was about causation when the only defensible
criterion is availability.

The second con is real and is worth the trade. "Rule 1 refuses this name, and
here is the coherence result for the file the loader would pick" is more
information than either half alone, and it tells a repairer what changes if they
remove the duplicate.

#### Answer to Q07: option G5 (with reason why it must be accepted as the answer)

Option G5. It keeps the third result type, which is what stops an unanswerable
input being scored as a pass, and it narrows it to the only criterion that can
be applied consistently. A rule that says "undetermined when the data was not
there" can be audited case by case; a rule that says "undetermined when
something related failed" cannot, and round 2 found two places where it gave the
wrong answer.

### Q08: what the D10 policy consumes, and what it returns

Question description: the issue decided D10 as a conditional policy and named
umbrella item 7 as the supplier of its evidence. Round 1 named the missing
interface. Round 2 refused the interface as specified, on a defect that makes
the policy unevaluable: the evidence described only the provider the archive
happens to ship, so nothing in it says what the OTHER candidate defines. An
archive carrying GCC 11 that fails cannot ask about GCC 12, and an archive
carrying GCC 12 that succeeds would be scored as GCC 11.

#### BBQ for Q08

A building code says the beam must carry the load. To evaluate it you need the
load, the catalogue of beams with their ratings, and a rule for choosing. A
report that gives the load and the rating of the beam already installed answers
whether TODAY holds. It cannot answer which beam to order, and if the installed
beam is oversized it will happily conclude that the smallest one would have
done.

In this picture: the load is the required node set, the catalogue is the
capability table for both generations, and the installed beam is whatever
generation item 7's reading was taken under.

#### Options for Q08

- Option H1: LEAVE THE INTERFACE TO ITEM 7.
  - con: item 7 would decide a policy the issue assigned here.
- Option H2: DEFINE THE RESULT ONLY, leaving the evidence shape open.
  - con: a result with an undefined input is not evaluable.
- Option H3: DEFINE BOTH ENDS, WITH THE EVIDENCE READ FROM THE SHIPPED PROVIDER.
  Consumer set, required nodes, what the shipped libstdc++ defines, and the
  companion `libgcc_s` reading.
  - con: refused in round 2. The second branch cannot be taken from it, and the
    first branch is wrong whenever the reading was taken under GCC 12.
- Option H4: REQUIREMENTS FROM THE ARCHIVE, CAPABILITIES FROM BOTH CANDIDATES.
  The evidence carries four fields: the READING GENERATION, which generation
  built the archive that was read; the CONSUMER SET, every static subject
  recording a `DT_NEEDED` on `libstdc++.so.6`, taken with this design's subject
  rule; the REQUIRED NODES those subjects record, `GLIBCXX_`, `CXXABI_` and the
  `GCC_` needs against `libgcc_s`; and a CANDIDATE CAPABILITY TABLE giving, for
  GCC 11 and for GCC 12, its identity and the nodes its `libstdc++` and
  `libgcc_s` define. The policy returns the LOWEST candidate satisfying every
  required node, or fails if neither does. If the returned candidate differs
  from the reading generation, item 7 rebuilds with it, re-reads, and
  re-evaluates; the second evaluation must return EXACTLY THE SAME CANDIDATE,
  and EVERY OTHER RESULT is non-convergent and fails: a higher candidate, a
  lower one, or neither satisfying. There is no third iteration.
  - pro: both branches are answerable from the evidence, which is what round 2
    asked for.
  - pro: the result depends on candidate capabilities and not on what happened
    to ship, so an archive already on GCC 12 is scored correctly.
  - pro: the re-read handles the fact that the required-node set is itself a
    product of the build, and the convergence rule stops that from becoming an
    unbounded search.
  - pro: binding the consumer set to this design's subject rule keeps the D10
    reading from being a second, weaker walk that misses the 76 extension
    modules.
  - con: item 7 must obtain capability data for a generation it did not build
    with, which is a real obligation and may mean reading a candidate toolchain
    rather than only the archive.
  - con: this design now owns an interface whose measurement it does not take.

#### Recommended option for Q08 (with arguments for this choice)

Option H4. H3 was the round 2 answer and round 2 found the hole by asking the
obvious question: with what does the policy compare GCC 12. There was no field
that could answer, so the second branch was decorative.

The obligation H4 places on item 7, obtain capabilities for both candidates, is
the minimum that makes a conditional choice a choice. The alternative the
reviewer offered, an iterative candidate-build procedure, is kept as the
fallback shape inside the re-read rule, so a party that cannot inventory a
generation without building it still has a defined path.

#### Answer to Q08: option H4 (with reason why it must be accepted as the answer)

Option H4. A policy that selects between two generations must be able to see
both, and the round 2 defect was not a wording gap but an interface that could
only ever describe one. The convergence rule is what keeps the re-read from
becoming an open search, and the inconclusive case for an empty consumer set
keeps an empty reading from being scored as satisfaction, which is the same rule
the live trace already follows.

### Q09: how the cross-root comparison is bound to the archive it describes

Question description: publication requires the cross-root comparison to be
present and passing for THIS archive, and nothing said what made it this
archive's. Round 3 found it, and closed the obvious escape at the same time: the
configuration digest cannot serve, because it identifies reusable policy bytes
and is deliberately identical across every archive built under that policy. A
valid, passing comparison from a different archive would satisfy the step as it
was written.

#### BBQ for Q09

A laboratory certificate can name the batch it tested or merely name the
standard it tested against. Every batch tested that month cites the same
standard, so the standard cannot tell two certificates apart. What distinguishes
them is a number taken from the batch itself, and the only person who can rely
on it is the one who takes the number again from the goods in front of them.

In this picture: the standard is the configuration digest, the certificate is
the verification result, the batch number is the archive digest, and taking it
again is publication computing it.

#### Options for Q09

- Option J1: THE OBSERVATION TRAVELS INSIDE THE ARCHIVE.
  - pro: it cannot be separated from the file.
  - con: impossible as stated. The archive's digest does not exist until the tar
    is closed, so nothing sealed inside it can name it, and co-location was
    already refused as a binding in round 2 for configuration.
- Option J2: A DIGEST-KEYED SIDECAR PAIR. Packaging retains its observation and
  keys it by the archive digest; verification keys its comparison the same way;
  publication recomputes the digest and requires both.
  - pro: the binding is real, and publication can check it by recomputation.
  - con: it keeps a transported packaging claim that publication must trust.
    The digest already rules out a claim that belongs to another archive; the
    real cost is retaining two evidence artifacts and authenticating two
    producers instead of deriving both observations under one verifier.
  - con: it compares the BUILD ACCOUNT against the installed tree, so a
    directory that existed where the tar was made but never entered the tar
    reads as present on both sides.
- Option J3: VERIFICATION DERIVES BOTH SIDES, AND ITS ONE RESULT IS KEYED BY THE
  ARCHIVE IDENTITY. The archive identity is the SHA-256 of the completed archive
  file's exact bytes. Verification reads the archive it is about to install,
  derives the pre-install observation from it, installs, derives the installed
  observation, compares, and emits ONE result recording both observations, the
  verdict, the archive identity and the configuration digest it worked under.
  Packaging's own observation stays local and is never transported. Publication
  computes the archive identity itself and requires a result naming that value
  and the configuration digest it resolved from cplx.
  - pro: one evidence artifact instead of two, and one producer instead of two.
  - pro: it compares WHAT THE ARCHIVE CARRIES against the installed tree, which
    is the more useful question: a directory that never entered the tar is
    exactly the gap this requirement exists to catch.
  - pro: the wrong-archive case and the altered-after-verification case both
    fall out of one recomputation, with no separate rule for either.
  - pro: nothing has to be trusted about a claim made on another host, because
    the build-side half is re-derived from bytes the verifier holds.
  - con: verification does more work, reading the archive twice in effect, once
    for its directory shape and once by installing it.
  - con: packaging's observation becomes a purely local gate, which is a smaller
    role than it had, and a reader may wonder why it exists at all.

#### Recommended option for Q09 (with arguments for this choice)

Option J3. Round 3 offered J2 and J3 as equally acceptable, and J3 is better for
a reason that is about correctness rather than economy: the divergence worth
detecting is between the ARCHIVE and the installed tree. A build-account
observation and an installed observation can agree perfectly while the archive
between them is missing a directory, and that is a delivery this design would
have passed.

The second con is worth answering rather than dismissing. Packaging's local
observation earns its place by refusing an UNEXPECTED directory before a tar is
built at all, which is cheap and early; it simply is not evidence anyone
downstream needs.

#### Answer to Q09: option J3 (with reason why it must be accepted as the answer)

Option J3. It gives step 2 of the publication order the identity it was missing,
by recomputation rather than by assertion, and it does so while removing a
transported artifact instead of adding one. The limit is stated in Design Area 7
rather than glossed: this binds the evidence to THESE BYTES, and it does not
authenticate that evidence against a party able to write both the archive and
the result. Publication re-runs the static checker itself in step 3 for exactly
that reason.
