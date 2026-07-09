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
  to point inside the deployed tree,
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

- [Relocate an install to another prefix](../how-to/relocate-an-install-to-another-prefix.md):
  the recipe.
- [Packaging and relocation tools](../reference/relocation-tools.md):
  the exact behavior of `pkg.sh` and `install_pkg.sh`.
- [The sandbox root](the-sandbox-root.md): where those absolute paths
  come from in the first place.
