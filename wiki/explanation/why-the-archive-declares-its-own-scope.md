# Why the archive declares its own scope

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

_Why the runtime closure checker compares a DECLARED shape against an
OBSERVED one instead of just looking at the tree, and why an archive
that describes itself still cannot vouch for itself._

## Looking at the tree answers the wrong question

The obvious way to check that a `tools` archive resolves its own
libraries is to walk the tree, collect every directory that holds a
`.so`, and confirm that every `DT_NEEDED` name is found in one of them.
That check passes on a tree that is wrong.

It passes because the set it checks against is derived from the tree
itself. A superseded interpreter root left behind under `tools/` is
still a directory full of libraries, so it joins the search set, and
every name it happens to satisfy is reported as resolved. The archive
then ships two generations of the same payload and the check calls it
closed. Ask the tree what it contains and it will always agree with
itself.

So the checker keeps two sets and refuses to merge them:

- the **declared candidate shape**, derived from
  `closure-config.txt` and touching no filesystem at all. It is what the
  archive is supposed to carry: two roots, their declared immediate
  subdirectories, and the library directories under those;
- the **observed loader scope**, which is `install_pkg.sh`'s own
  `build_elf_rpath` called over the real tree. It is what the loader
  will actually search at runtime.

A directory in the second that the first does not name is an UNEXPECTED
root. That is a refusal, and it is the one refusal no waiver can carry,
because a scope nobody declared is a scope nobody reviewed.

## The declaration is derived once and called twice

Both halves matter, and so does the fact that the observed half is
CALLED rather than reimplemented. A second implementation of the rpath
rule would drift from the installer's, and the day it drifted the
checker would be measuring a scope no loader uses. The checker sources
the installer and asks it, so the answer is the installer's own output
byte for byte, and the verification harness asserts exactly that.

The installer, for its part, gains nothing from the checker. It carries
no `readelf`, no `sha256sum` and no `tar -t`, and a grep over it runs at
every step of the effort to keep it that way. The gate runs at packaging
time; an install must stay the audited, minimal thing it already is.

## Every shipped object is a subject, not just the reachable ones

The same reasoning decides what gets examined. The tempting rule is the
transitive closure from the entry points: start at the binaries, follow
`DT_NEEDED` edges, and check what you reach.

That rule drops the files most likely to be wrong. CPython opens an
extension module by path, at runtime, from a directory listing. Nothing
static records that edge, so a closure from the entry points never
reaches `lib-dynload` or `site-packages`, and a measurement over the
real archive found 76 extension modules that no edge reaches. A checker
using reachability would examine the binaries, pass, and say nothing
about the majority of the objects that actually load.

So the subject set is every shipped ELF, taken from one walk of the
tree. Reachability may still describe a finding, and it never decides
membership.

## An archive can describe itself; it cannot vouch for itself

The bundle travels inside the archive, at `tools/closure/`, so a foreign
host with no cplx can read the declaration the archive says it was built
against. That is genuinely useful and it is strictly less than it looks.

An archive carrying its own declaration answers "what does this archive
claim to owe". It cannot answer "is that what cplx reviewed". The
identity envelope beside it carries the declaration's SHA-256, which
catches a bundle that was truncated, replaced or corrupted in transit,
and catches nothing at all in a paired edit: delete a floor entry, drop
the payload it protected, re-hash the document, and the archive is
internally consistent and wrong. The agent's check prints its own limit
on every run for that reason.

Authority comes from a party that has cplx. Publication resolves the
configuration from the repository at the release commit and requires the
archive's envelope digest to equal what it resolved ITSELF. Nothing the
candidate carries is taken as a fact; it is a claim to check.

The same rule decides which copies of the checker may produce evidence.
The five modules are staged into the archive, and they are payload:
useful to an operator debugging an installed tree, examined by the
authoritative checker like any other shipped file, and never executed to
produce a verdict about the archive they came out of. An archive that
certified itself would be proving which verifier bytes it happened to
contain, which is not the question. Byte-for-byte equality with the
reviewed copy does not change that: equality makes two files equivalent,
and it does not make a candidate-supplied script an independent judge.

## Two identities, doing opposite jobs

They look alike, and confusing them costs the whole boundary:

- the **configuration digest** identifies reusable POLICY. It is
  deliberately the same value for every archive built under one
  declaration, which is the point, since a policy that changed per
  artifact could not be reviewed once. It therefore cannot say which
  archive anything was observed on;
- the **archive identity** is the SHA-256 of the completed archive
  file's exact bytes, computed after the tar is closed. It identifies
  one artifact and nothing else.

Verification results are keyed to the second. Publication computes it
rather than reading it, so a result that describes some other archive is
refused by the identity rather than accepted by co-location.

## An empty observation is never a pass

One shape recurs through every part of this and is refused everywhere it
appears: a check that found nothing, reporting that nothing is wrong.

A walk that stopped early describes an empty tree. A live trace that
inventoried no process truthfully reports "no host library loaded". A
D10 reading that found no consumer of `libstdc++.so.6` satisfies every
candidate generation vacuously. Each of those is a true sentence about
an observation that was never taken, and each one reads exactly like a
green.

So the walk's own outcome is a separate input from any object's, the
live trace must name the process it inventoried, and an empty consumer
set is reported inconclusive. The rule is worth stating once because it
is the failure this whole gate exists to prevent, repeated at every
level: not being told a wrong answer, but being told nothing and reading
it as a right one.

## 👉 See also

- [Runtime closure checker](../reference/toolchain-runtime-closure.md):
  the scripts, the record shapes, the invariants and the exit codes.
- [Why binaries remember the build home](why-binaries-remember-the-build-home.md):
  where the rpath the observed scope is derived from comes from.
- [Two machines, one build](two-machines-one-build.md): why the
  packaging host and the host that runs the payload are different
  machines in the first place.
