# Install without the host rsync

- Type: issue
- Umbrella: docs/draft.v0.27.0.debian-agent-tools.md

## Split entry this draft comes from

| Order | Type | Key title | Slug | Status | Requirement | Validation plan |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Issue | Install without the host rsync | `rsync-cp-fallback` | pending | - | - |

Requirement detail recorded in the umbrella:

> Type: Issue. Slug: `rsync-cp-fallback`. Regroups work item 4 (Q19) and
> decision D4.
>
> `install_pkg.sh` calls `rsync` at two sites, the mirror-mode sync of
> the staging tree and the copy of each archive root file, and dies with
> exit 5 where the binary is absent, which is the case on the CI agent
> image. The fix detects `rsync` once, keeps using it when present so
> the build account path stays byte-identical, and otherwise falls back
> to a `cp` mirror that preserves the `--delete` semantics for
> redeployments over an existing prefix (empty the destination content,
> then `cp -a`), with a plain `cp -a` for root files. It must log which
> engine ran.
>
> Symlink fidelity belongs to the acceptance, and develop#24 is what
> makes it concrete: the runtime closure resolves `libgcc_s.so.1`
> through a link onto `libgcc_s-11-20240719.so.1`, and an rpath entry
> can itself be a link, `root/lib64` onto `usr/lib64`. A fallback that
> dereferenced links would silently double the tree, and one that
> dropped them would break the SONAME lookup, the failure class this
> collection exists to remove, arriving through the installer instead of
> the archive. `cp -a` preserves symlinks and hard links both, the
> latter being what `rsync -a` drops without `-H`, so the check is that
> the two engines produce the same tree, with that pair as the canary.
>
> First because it is the most independent change in the collection: one
> file, no rebuild, no packaging, verifiable against the existing
> published archive, and it retires a workaround that currently lives in
> the consuming project's pipeline. D4 also rejected shipping an rsync
> binary in the archive, so nothing here depends on the packaging items.
>
> Depends on: nothing.

## Why this matters: one archive, two distributions

The relocatable tools archive is built on a RHEL 9.8 account and now has
two consumers: the RHEL 9.8 deployment servers, where everything works
today and must keep working unchanged, and a CI agent made of throwaway
Docker containers running Debian 12, where the archive is relocated to
run tests, package and publish.

`install_pkg.sh` is the entry point of that relocation, and it has to
run on a bare foreign account before anything is installed. Its
bootstrap dependency set is today bash, tar, find, sed, grep, cp, ln and
mv, all POSIX baseline, plus `rsync`, the single outlier. The agent
image does not carry that outlier.

## Observed defect (Q19)

| Q | Defect | Evidence | Interim in the pipeline |
| --- | --- | --- | --- |
| Q19 | `install_pkg.sh` hard-requires `rsync`, absent from the agent image | first CI run: exit 5 at the mirror phase, `rsync: command not found` | rsync stand-in shim written by the pipeline before calling the installer |

The consuming project's pipeline currently writes a small stand-in on
the bootstrap `PATH` (options ignored, plain mirror copy). That
stand-in is exact only because CI installs into a fresh empty prefix,
which is why it cannot become the in-script answer as it stands.

## What has to change

File: `src/setups/env/bin/install_pkg.sh`, two call sites:

- line 454, mirror mode: `rsync -av --delete "$SOURCE_PATH/"
  "$DEST_PATH/"`;
- line 469, root files (`.env`, `.env_`): `rsync -av "$root_file"
  "$INSTALL_PREFIX/"`.

The in-script fallback must keep the real semantics for RHEL
redeployments into an existing prefix:

- mirror mode fallback: when `rsync` is absent, empty the destination
  (`rm -rf` of its content, not of the directory) then `cp -a` the
  source content; that reproduces `--delete` for the whole-tree case
  this script actually uses;
- root file fallback: plain `cp -a`.

Detect `rsync` once (`command -v`), log which engine runs, and prefer
rsync whenever present so the build account path stays byte-identical.

### Symlinks are load-bearing, so the fallback must keep them

The mirrored tree is not a bag of regular files. The archive's runtime
closure depends on link structure, which the CI probes made visible on
2026-08-08 (`develop#24` of the consuming project): the loader searches
for the SONAME `libgcc_s.so.1` while the real file is
`libgcc_s-11-20240719.so.1`, so a link carries the lookup, and a
directory named on the toolchain rpath can itself be a link, as
`root/lib64` is onto `usr/lib64`.

Two failure modes follow, both silent. A fallback that dereferenced
links would copy the target in place of every link, doubling the tree
and turning one physical library into several the relocation pass would
then patch separately. A fallback that dropped links would leave the
SONAME unresolvable, and the loader would fetch the host copy instead,
which is the mixed-runtime failure class this whole collection exists
to remove, arriving through the installer rather than through the
archive.

`cp -a` is the right tool: it implies `-d` and `--preserve=all`, so it
keeps symlinks as links and preserves hard links, the latter being
something `rsync -a` itself drops unless given `-H`. The point is not
that the choice is wrong, it is that the property is now known to
matter and must be verified rather than assumed.

## Decision D4, already settled

| # | Decision | Options | Outcome |
| --- | --- | --- | --- |
| D4 | How install_pkg.sh stops needing the host rsync | (a) in-script cp fallback; (b) ship the rsync payload in the archive like patchelf; (c) both; (d) wait for the agent image | decided: (a) |

The reasoning to preserve:

- (a) leaves the installer needing only POSIX tools, which is stronger
  than adding a binary that must itself be bootstrappable;
- (b) would drag rsync's `libpopt`, `libzstd`, `liblz4` and `libcrypto`
  onto a foreign distribution, the same failure class as the mixed
  runtime resolution already met with `libgcc_s` and `libstdc++`;
- compiling rsync inside cplx is impossible for this purpose: a
  cplx-built binary carries a `/home/<builder>` interpreter, which is
  precisely what the relocation pass repairs, and rsync is needed
  before that pass runs;
- asking the CICD team to add rsync (and procps) to the agent image
  stays a parallel, non-blocking track.

## Definition of done

- a relocation into a fresh empty prefix succeeds on a Debian 12
  container with no rsync present and no external shim;
- a redeployment over an existing populated prefix on RHEL removes what
  the new tree no longer carries, matching what `--delete` did;
- the run states which engine it used;
- with rsync present, the behavior and the resulting tree are unchanged;
- the two engines produce the same tree, links included: `libgcc_s.so.1`
  is still a link onto `libgcc_s-11-20240719.so.1` after a shim-free
  install, every directory named on the toolchain rpath keeps its nature
  (real directory or link), and no link has become a copy of its target;
- the relocated prefix still resolves: the shipped loader lists the
  python ELF and the toolchain libraries with no `not found` line that
  the rsync-produced tree did not already have;
- the consuming project can delete the rsync stand-in from its pipeline.
