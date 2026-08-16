# Relocate with RPATH so wheels resolve inside the prefix

- Type: issue
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

## Split entry this draft comes from

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | Issue | Relocate with RPATH so wheels resolve inside the prefix | `relocation-force-rpath` | pending | - | - |

Requirement detail recorded in the umbrella:

> Type: Issue. Slug: `relocation-force-rpath`. Regroups sub-task 3 of work
> item 3 (Q26) and decision D3.
>
> The relocation pass sets `--set-rpath`, which writes `DT_RUNPATH` on a
> modern ELF. A runpath applies only to the direct needs of the object
> carrying it, so it never reaches a library that a wheel extension
> dlopens, nor the libraries auditwheel grafts inside a wheel: this cost
> pikepdf its bundled libjpeg when the CI interim converted the wheel's
> own `DT_RPATH`. Passing `--force-rpath` restores RPATH semantics, which
> propagate down the whole loading chain, and the pass must cover every
> shipped library rather than executables alone, since the develop#19
> probe caught lone root libraries falling back on the host cache.
>
> Acceptance goes past `readelf -d`, because develop#24 measured what
> this item is worth: 110 of 388 inventoried ELFs are shipped libraries
> with no rpath of their own, 55 under each root, and re-probing after
> the pass should bring that to zero. Two specific readings tell whether
> it worked. The shipped `libstdc++.so.6.0.29` must stop taking host
> libm, libc and libgcc_s when probed alone, since `libgcc_s` does ship
> in `root/lib64`. And the eight `OPENSSL_3.x` nodes the probe reports
> missing on the root's libssl should disappear with them, that library
> finding its sibling libcrypto once it has a search path: if they
> survive the pass, the pairing is genuinely incoherent and requirement 4
> inherits a real defect rather than an artifact.
>
> Second because it is the other change confined to `install_pkg.sh`,
> needs no rebuild either, and can be proved against the current archive
> by re-running the relocation and re-reading the probe. Landing it
> before the packaging and build items means the definitive rebuild is
> validated with the final relocation semantics already in place.
>
> Depends on: nothing (adjacent to item 1 only because both edit the same
> file).

## Why this matters: one archive, two distributions

The relocatable tools archive is built on a RHEL 9.8 account and has two
consumers: the RHEL 9.8 deployment servers, where everything works today
and must keep working unchanged, and a CI agent made of throwaway Docker
containers running Debian 12 (bookworm, glibc 2.36), where the archive is
relocated to run tests, package and publish.

The relocation contract itself holds on the foreign distribution: after
the `install_pkg.sh` patchelf pass re-anchors interpreter and rpath (404
values on the measured run), the toolchain git 2.52.0 and the python ELF
`python3.13_bin` run fine on Debian. The failures the discovery met sit
in the margins of that contract, and library resolution falling back on
the host cache is the margin this item closes.

Whatever the loader cannot resolve from the shipped root it fetches from
the host `ld.so.cache`: on Debian that mixes glibc 2.36 objects into the
RHEL 2.34 process and dies (`GLIBC_ABI_DT_RELR`, `GLIBC_2.36 not
found`). The RHEL targets never see it, because their cache serves
compatible copies. That asymmetry is why this defect stayed invisible
until CI met a foreign distribution.

## Observed defect (Q26)

| Q | Defect | Evidence | Interim in the pipeline |
| --- | --- | --- | --- |
| Q26 | The wheels' own rpath hides the toolchain root, so manylinux extensions resolve Debian's copies against the RHEL libc; what the root actually lacks is narrower than first read, the runtime resolving inside the prefix once the python rpath governs | develop#10 pymupdf, develop#12 ld.so assertion, develop#13 `GLIBC_2.36` via libstdc++, develop#15 pikepdf grafted libjpeg, develop#21 clean runtime trace | `--replace-needed` onto `libc.so.6` plus a `--force-rpath` append of the root on every venv wheel; publish gated on a green walk |

Since glibc 2.34, `libpthread`, `libdl`, `librt` and `libutil` are merged
into libc, and the distribution ships tiny compat stubs for binaries that
still declare them. manylinux wheel extensions declare those stubs as
`DT_NEEDED` (pymupdf, develop#10), and their C++ ones need
`libstdc++.so.6` with its `libgcc_s.so.1` companion (pymupdf's `_extra`,
develop#13).

## What has to change

File: `src/setups/env/bin/install_pkg.sh`, the relocation pass
`fix_elf_paths()`.

`--set-rpath` writes `DT_RUNPATH` on a modern ELF. A runpath applies only
to the direct needs of the object carrying it, so it never reaches a
library that a wheel extension dlopens, nor the libraries auditwheel
grafts inside a wheel. `--force-rpath` restores classic `DT_RPATH`
semantics, which propagate down the whole loading chain.

Two halves, both needed:

- add `--force-rpath` to the `--set-rpath` call, so the python ELF's
  search list governs every object the process loads, wheels and their
  grafted libraries included, and the CI per-wheel append loop becomes
  unnecessary;
- extend the pass to every shipped library, not only the executables and
  the objects that already carry a builder-anchored rpath, since the
  probes caught lone root libraries falling back on the host cache.

### The mechanism in the current script, checked in the tree

Two details of the current pass matter for the second half, and they are
read from the file as it stands after item 1 landed (the umbrella's
"line 316" predates that change):

- `build_elf_rpath()` composes the search list from each tool directory:
  `root/usr/lib64`, `root/usr/lib`, `root/lib64`, `root/lib`, then the
  `lib` and `lib64` of every version directory below the tool, python
  first so its root libraries win. On the measured archive that yields
  the eight directories the probes inventory.
- `fix_elf_paths()` walks every file, keeps the ELFs, and rewrites the
  rpath only when the existing value already points under `/home/`
  (`if [[ "$old_value" == */home/* ]]`, guarding the `--set-rpath` call).
  The comment states the intent: keep the pass idempotent and leave
  system-linked binaries alone.

That guard is the measured cause of the second half. A shipped library
carrying no rpath of its own answers empty to `--print-rpath`, the empty
value does not match `*/home/*`, and the library is skipped. So the pass
never gives a search path to the objects develop#24 found flagged. Any
widening has to keep the guard's purpose while covering shipped
libraries that have nothing to rewrite yet.

Corrected 2026-08-16, from the round 1 specification review. This
paragraph first read the guard's purpose as "do not touch what the host
provides, stay idempotent across repeated relocations", and the source
comment it paraphrases says the pass leaves system-linked binaries
alone. Read literally, that would exclude the RPM-extracted libraries in
`root/usr/lib64`, which are exactly the objects the probe flagged and
which the requirement covers. The distinction is what ships, not who
built it: a library the archive carries is in scope even when a
distribution payload produced it, and what the guard protects is
programs and anything living on the host rather than in the prefix. The
idempotence half of the purpose stands, and
[the requirement](issue.v0.27.0.relocation-force-rpath.md) is
authoritative on both.

## What the probes measured

Four discovery runs walked this from inference to measurement, and the
later ones narrow the work rather than widen it.

- develop#19 flagged 72 ELFs and reported lone root libraries resolving
  libc host-side. Part of that was the root-object simulation artifact,
  part of it the real signal this item acts on. The same run's listing
  covered `root/usr/lib64` alone, which is what made two later readings
  of the draft wrong.
- develop#20 showed the live trace could not serve as acceptance in its
  then-current form: it reported no host library loaded while the same
  run's listing had `pymupdf` and `pikepdf` resolving `libgcc_s`
  host-side. The probe had to trace the venv python directly, one
  process rather than uv plus its child, and report how many trace files
  it wrote and kept, before a silent trace could count as a clean one.
- develop#21 made the two probes agree and explained the gap: the
  relocation gives the toolchain ELFs an rpath of eight directories,
  while the interim appends exactly one of them to each wheel and the
  probe inventories that same one. At run time the python ELF is the
  root object and its whole rpath governs every dlopen of the process,
  so the wheels resolve inside the prefix; a per-wheel listing sees the
  single appended directory and falls back to the host. The runtime
  reading was conclusive: `libgcc_s` carries an initializer (develop#19
  caught its `calling init`), the imports succeeded so its `DT_NEEDED`
  was satisfied, and no host library was initialized.
- develop#24 ran the widened probe over 388 ELFs from the eight
  directories plus the venv, and turned the inference into measurement:
  - zero wheels flagged, `pymupdf` and `pikepdf` included, so the static
    reading and the live trace agree at last;
  - `libgcc_s` located, shipping as
    `root/lib64/libgcc_s-11-20240719.so.1` under the python root and the
    git root alike;
  - 110 of 388 still flagged, all of them toolchain libraries probed in
    isolation, 55 per root and none from the venv.
    `libstdc++.so.6.0.29` is the representative case, taking host libm,
    libc and libgcc_s as a root object because the shipped libraries
    carry no rpath of their own. That is the measured argument for this
    item;
  - the only missing version nodes left, eight lines, are the libssl
    `OPENSSL_3.x` set, appearing under both roots.

That last point is the reading duty this item inherits, described under
the boundary below.

## Decision D3, already settled

| # | Decision | Options | Outcome |
| --- | --- | --- | --- |
| D3 | Stub resolution for dlopen'd wheels | (a) `patchelf --force-rpath` in the relocation pass; (b) keep `DT_RUNPATH` plus explicit `LD_LIBRARY_PATH` in CI and in the wrapper exec | resolved: (a) |

The reasoning to preserve:

- D3 is settled by evidence, not by preference. auditwheel writes classic
  `DT_RPATH` into wheel extensions precisely because RPATH propagates
  down the loading chain: develop#15 showed pikepdf's bundled libqpdf
  finding its grafted libjpeg only under RPATH semantics, and a converted
  `DT_RUNPATH` broke it;
- (b) would push the search list into the environment, which means every
  entry point (CI, the wrapper exec, an operator shell) has to carry it,
  and the python wrapper item exists precisely because an exported
  `LD_LIBRARY_PATH` is dangerous in the wrong process;
- RHEL harmlessness is not assumed: the validation matrix checks it on a
  deployment target, where host copies are compatible and the change
  should be invisible.

## Boundary with the other items

- Sub-tasks 1 and 2 of work item 3, the packaging-time closure check and
  the snapshot coherence rule, belong to requirement 4
  (`toolchain-runtime-closure`). Nothing here ships a library or prunes a
  generation.
- The wheel side needs nothing from requirement 4: develop#24 showed
  every venv wheel resolving inside the prefix once each wheel carries
  the search list the runtime uses, and that acceptance belongs here.
- The eight `OPENSSL_3.x` lines are a reading this item owes, not a fix
  it owns. The umbrella's requirement 4 defers explicitly: the probe
  reports them while listing libssl as a root object, where no rpath
  applies and the host libcrypto answers, and `import ssl` passes on
  every run, so the pair is probably coherent already. Re-probe once
  every shipped library carries an rpath, and only then decide whether
  requirement 4 has anything real to fix.
- Adjacent to requirement 1 only because both edit
  `src/setups/env/bin/install_pkg.sh`. Requirement 1 has landed, so this
  work starts from a tree that already carries the second copy engine.

## Definition of done

- the relocation pass writes `DT_RPATH` rather than `DT_RUNPATH`, and
  covers every shipped library, not only the executables and the objects
  that already carried a builder-anchored rpath;
- on a Debian 12 container, `uv sync` then
  `python -c 'import pymupdf, pikepdf'` in the project venv succeeds with
  no patchelf pass on any wheel, pikepdf exercising the grafted-library
  chain;
- re-probing the relocated tree brings the develop#24 flag count of 110
  out of 388 inventoried ELFs to zero, and the shipped
  `libstdc++.so.6.0.29` stops taking host libm, libc and libgcc_s when
  probed alone;
- the eight `OPENSSL_3.x` lines are re-read after the pass, and the
  verdict is recorded either way: gone, or genuinely incoherent and
  handed to requirement 4;
- both probe readings are conclusive when it is verified, the listing
  read over the whole rpath rather than one directory, and a live trace
  proving it looked at a venv process, develop#20 having answered "no
  host library loaded" for a run that had looked at nothing;
- on RHEL, a redeployment behaves as before: the pass is idempotent
  across repeated relocations, and the rpath of the objects it does not
  select stays untouched. Corrected 2026-08-16 from "system-linked
  binaries stay untouched", the second half of the same round 1
  correction recorded above, then refined in rounds 3 and 4. The selector
  is additive and is an **ordered** classifier, first matching case
  wins: an inspection failure, then an object with no dynamic section,
  then one already carrying the exact target value under `DT_RPATH`, then
  every shipped library whoever built it including the RPM-extracted
  ones, then the programs already holding the target value under
  `DT_RUNPATH`, then the remaining programs whose rpath still names the
  builder, and otherwise excluded. The order is what makes the outcome
  deterministic under the default `$HOME` prefix, where the deployed
  value itself contains `/home/` and the last two tests would otherwise
  both match. The migration case is bounded to a prefix relocated by
  v0.26.0, that being the predecessor this issue can recognize while
  `build_elf_rpath` stays unchanged. Every other program's **rpath**
  stays untouched, RPM-extracted programs among them; their interpreter
  is a separate matter, the interpreter guard being unchanged and free to
  rewrite a `PT_INTERP` this classifier never reaches.
  [The requirement](issue.v0.27.0.relocation-force-rpath.md)
  is authoritative;
- the consuming project can delete its `Q26 INTERIM, REMOVE` venv
  patchelf loop with its per-wheel `--force-rpath` append, and flip its
  walk-stage ABI contract probe from informative to blocking with an
  expected flag count of zero.

Relevant rows of the umbrella validation matrix:

| Check | Debian 12 container | RHEL 9.8 (build account or deployment target) |
| --- | --- | --- |
| `install_pkg.sh` relocation, no shim | required | required (redeploy over an existing prefix) |
| `uv sync` then `import pymupdf, pikepdf`, no wheel patching | required | required |
| ABI probe: shipped loader `--list` over toolchain ELFs and venv wheels, no `not found`, no host-resolved ABI-critical library | required | not applicable (host copies are compatible) |
| Live trace: `LD_DEBUG=libs,versions` on importing the heavy wheels, no ABI-critical library initialized from a host path, read from a conclusive trace | required | not applicable (host copies are compatible) |

The Debian side can run in any plain `debian:12` container holding the
archive and nothing else, against the existing published archive: this
item needs no rebuild and no repackaging to be proved.
