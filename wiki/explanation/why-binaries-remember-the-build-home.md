# Why binaries remember the build home

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

_Why a tool compiled under `/home/<builder>` refuses to start for an
account that cannot read that directory, and why it can silently keep
working for the accounts that can._

## Two paths are burned into every ELF binary

The forge links every tool against the sandbox root, with two absolute
paths taken from the build account's home
(`src/install/env/install_functions.sh`):

- the **program interpreter** (`PT_INTERP`): the dynamic linker the
  kernel loads to start the program, set by
  `-Wl,--dynamic-linker=<home>/cplx/tools/<tool>/root/lib64/ld-linux-x86-64.so.2`,
- the **rpath** (`DT_RPATH`): the list of library directories, set by
  `-Wl,-rpath=${LD_LIBRARY_PATH}`: absolute directories under the build
  home.

Python adds a third layer of absolute paths in text form: its
`configure --prefix` lands in `pyvenv.cfg`, `_sysconfigdata_*.py`,
pkgconfig `*.pc` files and console-script shebangs.

Note that the interpreter path points into the **build** tree
(`~/cplx/tools/<tool>/root`), not the promoted live tree (`~/tools`): even
the build account depends at runtime on the build tree still existing.

## The kernel reads PT_INTERP before any variable applies

`LD_LIBRARY_PATH` influences library lookup only. The interpreter path is
resolved by the kernel during `execve`, before the process exists, so no
environment variable can redirect it. When the recorded path is
unreadable, the program fails with the misleading message
`No such file or directory` even though the binary itself is present.

The rpath is no safer: a `DT_RPATH` entry wins over `LD_LIBRARY_PATH`, so
even a correct environment keeps loading libraries from the build
account's directories as long as they are readable.

## Why a same-group account can work by accident

An account in the same group as the builder (on the same server) can read
the build home, so its processes silently run the loader and libraries
from there. The install looks self-contained but is not: wiping or moving
the build home would break that account without any change on its side.
An account outside the group gets `Permission denied`: the honest
version of the same dependency.

## What the installer rewrites, and what it leaves alone

`install_pkg.sh` makes an install self-contained at unpack time:

- symlink targets and text files: `/home/<user>/` anchors are replaced
  with the installation prefix (`sed`), with the build-tree layout
  (`~/cplx/tools/`) mapped onto the deployed layout (`<prefix>/tools/`),
- ELF binaries: `PT_INTERP` and the rpath are rewritten with `patchelf`
  to point inside the deployed tree, except inside a venv (a directory
  holding `pyvenv.cfg`), whose wheel objects are never walked,
- `__pycache__` directories: removed, because their metadata keeps the
  build paths; Python rebuilds them on first import.

Two properties keep these passes safe to repeat: occurrences of the new
prefix are shielded behind a placeholder during the text rewrite (so a
prefix under `/home` is never rewritten into itself), and symlinks are
treated as values to re-anchor, never as paths to follow (only regular
files are edited or patched).

Strings compiled into read-only data (for example CPython's fallback
`PREFIX`) are not rewritten: they are only consulted when every other
lookup fails, and they are unreachable once the interpreter, rpath and
`pyvenv.cfg` are correct. A raw `strings` scan can therefore still show a
few `/home/<builder>` hits; the checks that matter are `readelf`, `ldd`
and an actual run.

## Could the forge side-step this at compile time?

Only partially. The three layers baked into a build have three different
answers, and only the first one can really move to compile time.

### Layer 1 (the rpath): mostly side-steppable

**Since v0.27.0 the install-time rewrite settles this layer at deployment
rather than at link time.** The pass writes `DT_RPATH`, not `DT_RUNPATH`, and
the choice carries two consequences worth stating plainly:

- **`LD_LIBRARY_PATH` no longer wins.** `DT_RUNPATH` is consulted after the
  environment, so anything on `LD_LIBRARY_PATH` outranked the shipped
  libraries; `DT_RPATH` is consulted before it. Setting `LD_LIBRARY_PATH` to
  point at a system library will not override a shipped one any more, which is
  the point: the prefix resolves against itself.
- **`setenv` stops deciding for the shipped objects.** For a program or
  library the pass rewrote, the `setenv` export no longer chooses which
  libraries load, because the object carries its own answer and that answer is
  consulted first. This holds only for objects the pass owns: the next section
  shows where the environment becomes load-bearing again.

`DT_RPATH` also applies transitively, to the dependencies of a shipped library
and not only to the program that started the lookup, which `DT_RUNPATH` does
not. That is what lets a shipped `.so` pull in another shipped `.so` instead of
the system copy.

### Where DT_RPATH stops: wheels with their own RUNPATH

An earlier version of this page concluded that the interpreter's `DT_RPATH`
also resolves everything the venv's wheels load, since the python ELF is the
root object of the process. A run on the foreign CI agent disproved it.

The loader's rule is per requesting object: when the object that needs a
library carries a `DT_RUNPATH`, **no** `DT_RPATH` is consulted for that
lookup, neither its own nor the one of any object above it in the loading
chain. Some manylinux wheels ship extensions with a `DT_RUNPATH` holding an
`$ORIGIN` entry, which is how they find the libraries bundled beside them.
For their other needs (`libstdc++.so.6`, `libgcc_s.so.1`) the search order is
then `LD_LIBRARY_PATH`, that `DT_RUNPATH`, and the host cache. The prefix's
copies are simply not in it.

On the build distribution nobody notices, because the host copies are
compatible. On another distribution the host copy demands version nodes the
shipped libc, already loaded by the interpreter, does not define, and the
process fails. Two consequences follow, and both are settled:

- **wheel objects are never rewritten.** The installer's ELF pass skips every
  venv tree; replacing a wheel's `$ORIGIN` with the prefix list removed the
  only entry through which it finds its bundled providers;
- **the search path is supplied per command, by the consumer.** A consuming
  application keeps one versioned runtime setup, shared by its CI and its
  deployment, that puts the shipped library directories (the same list the
  installer's `build_elf_rpath` computes) first in `LD_LIBRARY_PATH` for the
  shipped Python and application commands only. It is applied at that command
  boundary and never exported into an operator shell, because a host program
  started with the shipped libc on its path fails the same way the old Python
  wrapper did ([Python wrapper](../reference/python-wrapper.md)).

So `LD_LIBRARY_PATH` is not obsolete. It no longer decides for the toolchain
objects, and it is still the only mechanism that reaches a wheel with its own
`DT_RUNPATH`.

### Layer 1 at compile time: the `$ORIGIN` alternative

What follows is the compile-time alternative, kept because it explains why the
install-time pass exists rather than the other way round.

Linking with `$ORIGIN`-relative entries (`$ORIGIN` expands, at load
time, to the directory of the binary being loaded) plus
`--enable-new-dtags` (which emits `DT_RUNPATH` instead of `DT_RPATH`,
letting `LD_LIBRARY_PATH` take precedence again) would make library
lookup relocatable for any prefix, forever. It is fiddly with the
current layout, though:

- binaries sit at several depths (`<tool>/current/bin`,
  `root/usr/bin`), so no single `LDFLAGS` value fits all of them;
- some rpaths are cross-tool (python's `_ssl` module points into the
  openssl root), so the entries encode the relative shape of the whole
  tree, not just of one tool;
- the build tree (`~/cplx/tools/<tool>/root`) has a different shape
  than the deployed tree (`<prefix>/tools/...`), so `$ORIGIN` entries
  valid after deployment are wrong for the test programs `configure`
  runs during the build itself.

Even done perfectly, this only shrinks the patch pass: the next two
layers remain.

### Layer 2 (the interpreter, PT_INTERP): not side-steppable in general

There is no `$ORIGIN` for the interpreter: the kernel resolves it as an
absolute path at `execve`, before any environment or loader logic
exists. The only compile-time escape is pointing at the system
`/lib64/ld-linux-x86-64.so.2`, valid only when the sandbox glibc
matches the server glibc (the common case, since the root is unpacked
from the server's own RPMs), and invalid the day a recompiled
glibc/gcc ships to an older server, which is one of the reasons cplx
exists. The wrapper alternative (an `exec <ld.so> --library-path ...`
script in front of each binary) bypasses `PT_INTERP` entirely but
confuses everything that inspects its own executable: Python's
`sys.executable`, shebangs, subprocesses.

### Layer 3 (the text paths): never side-steppable

Python's `configure --prefix` lands in `pyvenv.cfg`,
`_sysconfigdata_*.py`, pkgconfig `*.pc` files and console-script
shebangs no matter how the binaries are linked. These are beyond the
linker entirely; only an install-time rewrite can re-anchor them.

### Patch-at-install is the industry standard, not a workaround

No compile-time change eliminates the installer; at best it makes the
ELF pass smaller. And rewriting at install time is exactly what the
established binary-distribution systems do: **conda** records a long
placeholder prefix at build time and rewrites it (text files and
binaries alike) in every package it installs; **Nix** sets interpreters
and rpaths with `patchelf`, the same tool `install_pkg.sh` uses.
cplx independently converged on the same design: ship the installer
with the package, and make relocation a normal, repeatable step of
deployment rather than chasing a fully relocatable link.

## 👉 See also

- [The sandbox root](the-sandbox-root.md): where those absolute paths
  come from in the first place.
- [One archive, two distributions](one-archive-two-distributions.md): why
  the wheel boundary only showed on a foreign distribution.
- [Relocate an install to another prefix](../how-to/relocate-an-install-to-another-prefix.md):
  the recipe.
- [Packaging and relocation tools](../reference/relocation-tools.md):
  the exact behavior of `pkg.sh` and `install_pkg.sh`.
