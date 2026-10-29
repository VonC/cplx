# Design v0.27.0 -- Ship a complete runtime closure in the archive

## Publication response-loss resolution (2026-09-17)

The tools rebuild live probe showed that a commit can become public while its
response is lost. The user requires the publisher to double-check such an
attempt. This resolves the later plan's assumption that a failed callback proves
absence: remote atomic visibility and client acknowledgement are separate facts.

Preserve the open-descriptor stream, independent pre-commit SHA-256 comparison,
private unfinished stage and immutable destination. Before completing the remote
request, persist the attempt, exact coordinate and expected digest. Missing or
unusable commit responses require an immediate independent GET of that asset
and a SHA-256 comparison over the returned bytes. A match confirms publication.
No match, absence or unavailable verification leaves the outcome unknown,
blocks adoption and automatic re-publication, and retains recovery diagnostics.
Later reconciliation performs the same read-only check without uploading again.

The four adapter signatures stay unchanged. Commit returns 0 only after a valid
acknowledgement or matching read-back, and 3 for an unresolved outcome. Cleanup
closes unfinished uploads; after commit intent it reconciles instead of deleting
the release or claiming absence. These rules supersede the original plan's
commit-failure postcondition. Implementation and fixtures are owned by
[tools rebuild Step 1](plan.v0.27.0.tools-archive-rebuild.md#step-1-demonstrate-the-real-publication-transaction).

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

THAT FINDING HAS TWO HALVES AND THEY DO NOT ARRIVE TOGETHER, amended here on
2026-09-07 after the step 3 code review found the design owed an input no step
supplied. The paragraph above stated a conjunction and named no source for its
first term, which left an implementation able to compute one half and unable to
say so honestly.

| Half | What it reads | Where it comes from |
| --- | --- | --- |
| UNREFERENCED-BY-EDGE | no `DT_NEEDED` edge of any subject resolves to this object | the edges the static walk already collected |
| UNREFERENCED-BY-ENTRY-POINT | no declared entry point is this object | THE DECLARED ENTRY-POINT SET, which is configuration |

THE DECLARED ENTRY-POINT SET IS A CONFIGURATION DECLARATION, in the same document
the roots, the floor, the families and the waivers live in. It lists LOCATIONS
relative to the archive whose shipped ELF objects are entry points: the
interpreter, the directories the shipped executables live in, and the
dynamically loaded locations, `lib-dynload` and `site-packages` among them, that
the interpreter opens by path. It is declared and not derived, for the reason
this whole area exists: the loading mechanism at issue leaves no static trace, so
a heuristic over file names or permission bits would be wrong in both directions.

UNTIL BOTH HALVES EXIST, A CHECKER REPORTS THE HALF IT HAS UNDER THAT HALF'S OWN
NAME and never as this finding. Reporting the edge half as the whole would name a
shipped executable, which is an entry point by definition, as an object nothing
can load.

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

### Packaging preparation for loader identity

Requirement Q12 adds a packaging preparation before the checker: preserve the
installer-selected loader and replace only byte-identical regular copies of
`ld-linux-x86-64.so.2` with relative aliases to it. Existing aliases remain.
Preparation checks all candidates before writing any, refuses broken or
escaping paths, and works only in the owned stage. The installer therefore sees
one loader identity at every preserved name and its existing identity exclusion
protects the bytes. This does not change either duplicate-provider checking or
the installer. Step 8 retains source, archive and installation inventories plus
explicit loader invocation and runtime checks.

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
| packaging | NO, corrected in v0.27.0 step 5 | cannot; it verifies the envelope deployed with the declaration | the document it embeds hashes to the digest its envelope names | mismatch, or an absent declaration or envelope |
| verification, Debian agent | no | cannot | the embedded document hashes to the digest its envelope names | absent, substituted or corrupted configuration |
| publication, umbrella item 7 | yes | RESOLVES IT ITSELF, at the release commit being published, independently of anything the archive says | the archive's envelope digest equals the digest of the configuration publication resolved | any difference, and any active waiver |

THE FIRST ROW WAS WRONG ABOUT A FACT, and step 5 corrected it against the
account rather than against the document. Packaging runs on a build account that
has NO cplx checkout: cplx arrives there as copied scripts, `pkg.sh` has never
named Git in its life, and `install_pkg.sh` prunes `.git` as debris. The
resolution that row described could not happen, and the only checkout on that
account is a year stale, so performing it would have staged an old declaration
while calling it authoritative.

The correction costs nothing this design claimed, and the paragraph below is why:
packaging's read was never the binding. The envelope is a COMMITTED FILE beside
the declaration, and it travels with it; nothing resolves a commit at deploy
time and nothing produces the envelope on the way. Packaging verifies it, which
is the same check the second row already describes for the agent, and the commit
the envelope names is a record of which reviewed version the declaration is
rather than a check packaging can perform.

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

Requirement Q13 permits a separate CI transport operation for the sqlite-waived
Step 8 validation candidate. It uses a digest-pinned temporary snapshot, requires
the full Q15 RHEL report, disables application publication, leaves the release
pin intact and removes the temporary transport after evidence retention. The
five-step release publication operation below has no validation bypass.

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
over the installed tree. ACCEPTANCE REQUIRES THE LIVE OBSERVER ON THE FOREIGN
HOST, because only a process demonstrates runtime fallback behavior there.
The same observer can also run on build and deployment hosts.
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

Dynatrace OneAgent monitoring is outside runtime-closure scope on every host,
including release verification, by the owner's decision. The authoritative
live observer recognizes `liboneagent?*.so` vendor modules in subdirectories of
`/opt/dynatrace/oneagent/` and in standard `/lib`, `/lib64`, `/usr/lib`,
`/usr/lib64` and x86-64/AArch64 GNU system-library directories. It rejects
lookalike roots, dot traversal and ordinary libraries in the vendor directory.
The recognition is independent of the agent version, digest or proof of its
injection mechanism. The kernel's ` (deleted)` suffix is retained in the trace
and does not invalidate recognition during an agent upgrade.

Each mapped object remains visible. External OneAgent objects are classified
`excluded-dynatrace`; `HOSTS` remains the raw external count, `EXCLUDED` records
the Dynatrace count, and `FALLBACKS` records external objects still in scope.
A conclusive live pass requires a usable non-monitoring inventory and zero
`FALLBACKS`, and its summary explicitly reports the exclusions. Monitoring
alone is inconclusive. Ordinary external runtime libraries still refuse even
beside an excluded agent. No namespace or preload configuration change is
required. The static checker continues to judge the complete candidate scope.

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
| a shipped ELF that no `DT_NEEDED` edge resolves to, otherwise sound | ACCEPTED, and reported UNREFERENCED-BY-EDGE | unreferenced is a finding, never an exclusion, and this is the half the static edges answer |
| the same object, where the declared entry-point set names it | NOT reported once that set exists | a shipped executable is an entry point by definition |
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
| a floor entry deleted in the same edit that removes the payload, and the document re-hashed to match its own envelope | the Debian agent ACCEPTS, PACKAGING ACCEPTS since v0.27.0 step 5, and PUBLICATION refuses | the paired edit, caught only where cplx is visible, and packaging is not: it has no checkout, so it verifies the same self-consistency the agent does. Publication resolves the declaration itself and is where this is caught |
| the bundle replaced with a different, internally consistent, authentic bundle | the Debian agent ACCEPTS it, and publication refuses on the digest it resolved itself | co-location binds nothing; publication's own resolution does |
| the named cplx commit does not hold that configuration at that path | PUBLICATION refuses; packaging cannot see it | corrected in v0.27.0 step 5: the source is a path at a commit and only publication can read it, because packaging runs where there is no checkout |

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

## Design decisions for v0.27.0 toolchain-runtime-closure

Settled across four design review rounds, closed on 2026-09-03 and recorded in
[the review transcript](review.design-specification.v0.27.0.toolchain-runtime-closure.md).
Three of the four rounds repaired a defect rather than refining wording, and the
rows below name them: a comparison that rested on a claim packaging cannot
observe, a configuration whose authority was asserted instead of resolved, and
evidence that described no particular archive.

AMENDED ONCE SINCE, ON 2026-09-07, and recorded here rather than folded into the
rows above, because a decision table that changes silently is worth less than the
rounds that produced it. The step 3 code review found that
`Four sets, kept apart` defined the unreferenced finding as a conjunction whose
first term had no declared source anywhere in this design or in the plan that
schedules it: an implementation could compute the edge half and had no honest way
to report it. The amendment is Q13 below, and the section it changes carries the
same date.

| Question | Decision | Integrated in | Rejected alternatives |
| --- | --- | --- | --- |
| Q01 | The candidate shape is DECLARED, as a root list plus a subdirectory list, so an alias such as `current` is declared rather than refused, while the loader scope stays OBSERVED. Verification derives both sides from the archive it is about to install, so no packaging claim is transported. | Design Area 1: `The candidate shape is declared; the loader scope is observed`, `Where the comparison actually happens`, `One derivation, two callers` | A1, one shared derivation both callers invoke; A2, the installer emits the shape; A3, a written spec both implement; A4, the declared shape with the comparison still taken at packaging time |
| Q02 | Two scopes, stated separately: the declared roots the invariants read, and the loader scope actually observed. An unexpected root, `tools/old/py3.13` in the measurement, is its own refusal and is UNWAIVABLE, so it must be removed or declared before a green run. | Design Area 1: `Declared roots, declared subdirectories, and the measured old/ root`. Design Area 2: `Refuse, never prune` | B1, every `tools/*` root in scope; B2, non-current roots excluded; B3, the loader-following scope without the declared list; B4, the same with a root waiver |
| Q03 | One mechanism defines the four archive invariants and runs on both the build account and the Debian agent. A separate live observer runs on the foreign host only, and verification combines the two typed results. Packaging's verdict is explicitly partial. | Design Area 5: `What runs where, stated once`. Design Area 2: `Version coherence, resolved through the provider the object names` | C1, one mechanism with a packaging mode and a verification mode; C2, two mechanisms sharing declared configuration only |
| Q04 | The configuration bundle travels in the archive in two parts, and only the hashed part is POLICY identity. The Debian agent checks consistency rather than authority, and publication resolves the authoritative bundle from cplx instead of trusting the copy the archive carries. | Design Area 3, all six subsections, in particular `Self-describing is not the same as authoritative` and `The configuration digest is POLICY identity, and never evidence identity` | D1, the configuration travels with the pipeline; D2, it travels in the archive and is trusted for being there; D3, a copy beside the probe plus an identity manifest; D4, the bundle carrying its cplx identity without the publication-side resolution |
| Q05 | Publication re-checks in a fixed five-step order over the exact archive, with step 2 keyed by Q09's archive identity: publication computes the digest itself and requires a verification result naming that digest and the configuration digest publication resolved. Missing policy, comparison, static validity or waiver state fails closed. | Design Area 4: `The publication re-check, in a fixed order` | E1, a marker inside the archive; E2, a marker beside it in publication metadata; E3, a re-evaluation with no named inputs; E4, the same without publication-side configuration resolution |
| Q06 | Every shipped ELF is a static subject. Four sets stay apart: subjects, provider directories, entry points and live observations. Reachability may describe a finding and never decides membership, because the loading mechanism at issue leaves no static trace. | Design Area 2: `Four sets, kept apart`, `The static subject set is every shipped ELF, and the measurement says why`. Design Area 6, which binds the D10 consumer set to the same subject rule | F1, every shipped ELF with no separation between the four sets; F2, only objects inside the provider directories; F3, the transitive closure from the entry points |
| Q07 | A complete inventory whose suppression follows DATA AVAILABILITY alone. UNDETERMINED is reserved for an input that was not there, so an independent deterministic result is never erased by an unrelated refusal. | Design Area 5: `Aggregation follows data availability, not the presence of another refusal` | G1, fail fast at the first refusal; G2, a flat complete inventory; G3, a complete inventory with a fixed order; G4, suppression driven by other refusals |
| Q08 | The D10 policy takes requirements from the archive and capabilities from BOTH candidate generations, returns the lowest satisfying candidate, and reports an empty consumer set as inconclusive. Any non-identical re-read fails as non-convergent. | Design Area 6: `The evidence item 7 produces`, `The result the policy returns`, `When the reading must be taken again` | H1, leave the interface to item 7; H2, define the result only; H3, define both ends with the evidence read from the shipped provider alone |
| Q09 | Verification reads the archive it is about to install, derives the pre-install observation from it, installs, derives the installed observation, and emits ONE result keyed by the SHA-256 of the completed archive bytes. Packaging's observation stays local, and publication recomputes that identity. | Design Area 7, all four subsections, in particular `How publication proves the evidence is this archive's` and `What this area does not do` | J1, the observation travels inside the archive, impossible because the digest does not exist until the tar is closed; J2, a digest-keyed sidecar pair, which keeps two evidence artifacts and two producers |
| Q13 | The unreferenced finding has TWO HALVES with separate inputs, amended 2026-09-07 after the step 3 code review. The EDGE half is computed by the static checker from the collected `DT_NEEDED` edges and is reported under its own name, `UNREFERENCED-BY-EDGE`. The ENTRY-POINT half needs the DECLARED ENTRY-POINT SET, a configuration declaration of the locations whose shipped objects are entry points, and it is scheduled where that declaration lands rather than assumed available. A checker that has one half reports that half by name and never as this finding. | Design Area 2: `The static subject set is every shipped ELF, and the measurement says why`, and its acceptance rows | M1, deriving entry points from PT_INTERP or a permission bit, a heuristic this area already refuses for the same reason; M2, leaving the conjunction stated with no source, which is what the review found; M3, dropping the entry-point half entirely, which would stop the design saying that a shipped executable is reachable by definition |
