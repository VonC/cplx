# Runtime closure checker

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

The gate that refuses to package a `tools` archive whose libraries do
not resolve inside the archive. It runs on the build account before the
tarball is created, again on a foreign host after the archive is
installed, and a third time at publication, over the same declaration
each time.

The scripts live in `src/setups/env/bin/`, beside `pkg.sh` and
`install_pkg.sh`. The declaration lives in `src/setups/env/closure/`.

## The ten scripts, and where each one runs

| Script | Runs on | How it gets there |
| --- | --- | --- |
| `closure_check.sh` | build account, and the Debian job | in cplx for packaging; delivered to the job workspace at the resolved cplx commit |
| `closure_config.sh` | the same | sourced by `closure_check.sh`: the grammar, the digest, the envelope check |
| `closure_elf.sh` | the same | sourced: the object reader and the provider index |
| `closure_report.sh` | the same | sourced: the summary, the evidence record and its store |
| `closure_rules.sh` | the same | sourced: all four invariants and the waiver outcomes |
| `closure_verify.sh` | the Debian job | delivered by the pipeline, run OUTSIDE the candidate archive |
| `closure_observe_live.sh` | the foreign host | delivered with it, invoked by `closure_verify.sh` |
| `closure_publish.sh` | the publication host | cplx only, never staged into an archive |
| `closure_d10.sh` | the build account | cplx only, consumed by the archive rebuild |
| `ci/deliver-closure-tools.sh` | the Debian job, first | run from the cplx checkout; it PLACES the five authoritative copies |

The first five are also copied into the archive at `tools/bin/`, for an
operator debugging an installed tree. Those copies are payload: the
authoritative checker examines their bytes like any other shipped file
and reports the comparison, and an embedded copy is never executed to
produce evidence, including when it is byte-identical.

## `closure_check.sh [--prefix DIR] [--installer PATH] [--bundle DIR] [--root NAME[=SUB,SUB...]]`

Checks the tree under `<prefix>/tools`. At least one of `--root` and
`--bundle` is required, since the declared shape has to come from
somewhere. `--root` is repeatable and its order is the loader's order,
`python` first.

| Option | Meaning |
| --- | --- |
| `--prefix` | the installation prefix holding `tools`; defaults to `$HOME` |
| `--installer` | the `install_pkg.sh` whose `build_elf_rpath` supplies the observed loader scope |
| `--bundle` | the directory holding `closure-config.txt` and `closure-envelope.txt` |
| `--root` | one declared tool root and its declared immediate subdirectories |

`pkg.sh tools` runs it for you, with `--prefix "$HOME"` and the staged
bundle, and unstages everything it staged when the gate refuses.

Exit codes:

| Code | Meaning |
| --- | --- |
| 0 | the tree is closed |
| 1 | at least one invariant refused, and the run names what it refused |
| 3 | nothing refused, and an accepted exception carried the run: the archive is a VALIDATION ARTIFACT and publication will refuse it |
| 5 | an input could not be obtained, so a question stayed open. Not a softer 0 |

## Two scopes, and they are never merged

The **declared candidate shape** is derived from the configuration and
touches no filesystem: the roots, their declared immediate
subdirectories, and the library directories under them. It says what
the archive is supposed to carry.

The **observed loader scope** is `install_pkg.sh`'s own
`build_elf_rpath`, called rather than reimplemented, over the tree as it
actually is. It says what the loader will actually search.

A directory in the observed scope that the declaration does not name is
an UNEXPECTED root, and it is a refusal no waiver can carry. Comparing
the two is the only way a superseded tool root left behind in `tools/`
becomes visible.

## The four invariants, plus the floor

| Invariant | Refuses when |
| --- | --- |
| derived membership | a `DT_NEEDED` name recorded by a shipped object resolves nowhere in the observed scope |
| version coherence | the provider the loader would select does not define a version node the object demands of it |
| rule 1, duplicate providers | one lookup name has candidate paths whose CONTENT differs |
| rule 2, family generations | a declared family carries more generations than its entry permits |
| the declared floor | a floor member is absent, or present only outside its required location |

No invariant deletes anything. Every one refuses and names what it
refused, and the repair is a payload or configuration change made
deliberately.

The static subject set is **every shipped ELF**, taken from one `find`
walk of the tree. It is not the transitive closure from the entry
points: the interpreter opens an extension module by path and leaves no
static trace, so a closure would silently drop the modules under
`lib-dynload` and `site-packages`.

An UNDETERMINED result means one thing only: an input could not be
obtained. It is neither a pass nor a failure, it is reported with the
input it lacked, and it never counts toward a green.

## The configuration bundle

`src/setups/env/closure/closure-config.txt`, a `CPLX-CLOSURE/1` record
stream: a version line, then one record per line, fields separated by
`|`, no empty field, `%7C` for a literal `|` and `%25` for a literal
`%`. Blank lines and `#` comments are ignored, because a person writes
this file.

| Record | Shape |
| --- | --- |
| `root` | `root\|<root-name>` |
| `subdir` | `subdir\|<root-name>\|<subdir-name>` |
| `floor` | `floor\|<lookup-name>\|<location>` |
| `family` | `family\|<family-name>\|<soname-glob>\|<generations>` |
| `entrypoint` | `entrypoint\|<location>` |
| `waiver` | `waiver\|<lookup-name>\|<owning-requirement>` |

Ordering is significant for `root` and for nothing else. A `location`
other than `any` is exactly `tools/<root-name>` with a declared root.

Beside it, `closure-envelope.txt`, a `CPLX-CLOSURE-ENVELOPE/1` document
carrying the SHA-256 of the declaration's exact bytes and the path and
commit those bytes came from. It is committed, it travels to the build
account the way every other cplx file travels, and packaging verifies
that the pair agrees rather than producing it. When the declaration
changes, the envelope is regenerated in the same commit.

**The digest is policy identity and never evidence identity.** It is
deliberately the same value for every archive built under one
declaration, so it cannot say which archive anything was observed on.
The value that can is the archive identity: the SHA-256 of the completed
archive file's exact bytes, computed after the tar is closed and never
over an unpacked tree.

## The waiver contract

A waiver is an exception with an expiry condition, not a mute. Each one
names a floor member and the requirement that owns its removal, and the
model produces three failures of its own:

| Outcome | Meaning |
| --- | --- |
| unknown | the waiver names a member the floor does not declare |
| stale | the condition that justified it no longer holds |
| active | the waiver applied, so the run did not pass: exit 3, a validation artifact |

**Publication refuses any active waiver, with no mode and no flag that
permits one.** An UNEXPECTED root is unwaivable by construction: the
scope refusal is counted into the verdict and returns 1 long before the
exception question is reached.

## Verification on a foreign host, and publication

`closure_verify.sh` runs on the Debian agent from the pipeline
workspace, never from inside the candidate. It reads the archive before
installing it, installs it, re-reads it, compares the two presence
observations, runs the static checker, and invokes
`closure_observe_live.sh` for the live half. Both readings are required
to be conclusive: a listing over the whole provider set AND a live trace
that names the process it inventoried, because a trace that inventoried
nothing once reported "no host library loaded", a true sentence about an
empty observation that reads as a pass.

The result is a `CPLX-CLOSURE-EVIDENCE/1` document, keyed to the archive
identity, written by a machine and therefore refusing the blank lines
and comments the other two grammars ignore. Its verdict is DERIVED from
its own records when it is read back: a document asserting PASS over a
divergent pair is refused.

`closure_publish.sh` is the last thing that can refuse an archive, and
it takes no policy and no evidence from the archive. In order: compute
the archive identity, resolve the authoritative configuration from cplx
at the release commit and require the archive's envelope digest to equal
it, require a verification result keyed to that identity, re-run the
static checker against the configuration publication resolved, and
refuse on any active waiver.

## The C++ generation policy

`closure_d10.sh` answers which libstdc++ generation the archive should
ship. It takes the requirements from the archive and the capabilities
from BOTH candidate generations, and returns the lowest candidate that
defines every required node.

| Function | Answers |
| --- | --- |
| `closure_d10_evidence` | the reading: the reading generation, the consumer set, the required nodes, and one capability entry per candidate |
| `closure_d10_policy` | the lowest satisfying candidate, `NEITHER`, or `INCONCLUSIVE` |
| `closure_d10_converge` | whether a re-read after a rebuild returned the same candidate |

The consumer set is every shipped ELF recording a `DT_NEEDED` on
`libstdc++.so.6`, the same subject rule the checker uses. Requirements
are the `GLIBCXX_` and `CXXABI_` needs recorded against `libstdc++` and
the `GCC_` needs recorded against `libgcc_s`.

**Zero spare nodes is allowed**: the condition is satisfaction, not
headroom. "The margin is gone" is deliberately not the threshold,
because it is ambiguous between zero headroom and an unsupported node
and only the second is a failure.

If the returned candidate differs from the generation the reading was
taken under, the archive is rebuilt with it and the reading is taken
again. **The second evaluation must return exactly the same candidate.**
A higher one means the requirement set grew with the generation, a lower
one means the first reading overstated what the archive needs, and
neither satisfying means the rebuild moved the requirements out of
range. All three fail as non-convergent, and there is no third
iteration.

A consumer set of zero is reported inconclusive and never as a satisfied
condition, and so is a candidate whose providers could not be read: an
unmeasured generation is not an unsatisfying one.

Exit codes: 0 a candidate satisfies, 1 neither does, 2 the arguments are
unusable, 5 the evidence could not answer.

## 👉 See also

- [Why the archive declares its own scope](../explanation/why-the-archive-declares-its-own-scope.md):
  why the shape is declared, and why a self-describing archive is not an
  authoritative one.
- [Packaging and relocation tools](relocation-tools.md): `pkg.sh` and
  `install_pkg.sh`, which the gate runs beside.
- [Why binaries remember the build home](../explanation/why-binaries-remember-the-build-home.md):
  the rpath the observed scope is derived from.
- `src/setups/env/closure/README.md`: the digest domain, stated beside
  the data it governs.
