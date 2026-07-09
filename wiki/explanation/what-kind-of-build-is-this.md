# What kind of build is this

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

_There is no single canonical name for what cplx does, but every piece
of it has one. In one line: **native, from-source, unprivileged prefix
builds against an RPM-derived sysroot, made relocatable at install
time**, or informally, a hand-rolled Spack for offline RHEL servers._

## Native compilation

The Linux server compiles for itself: build machine and target machine
are the same. Despite the two-machine workflow, the Windows side only
downloads sources and packages
([Two machines, one build](two-machines-one-build.md)); no code
generation happens there. This matters because native builds can run
their own test programs: `configure` probes the real target at build
time, which a cross-build cannot do.

## Sysroot build

The distinctive part. `install_functions.sh` passes `--sysroot=${root}`
to both the compiler and the linker, so headers and libraries resolve
inside the synthetic root assembled from unpacked RPMs
([The sandbox root](the-sandbox-root.md)) instead of `/usr`. The flag
and the technique come from the cross-compilation world: a
cross-toolchain always compiles against the target's sysroot. cplx uses
it natively, as a way to compile against exact, chosen dependency
versions without root and without ever touching the system directories.
"Native build against a synthetic sysroot" is the most precise
description of the forge.

## Unprivileged prefix build

Everything installs under `$HOME` via `--prefix` (also called a
"userland" or "non-root" install): no root, no system package manager
involved, several versions side by side with a `current` symlink as the
switch. This is the model whole ecosystems are built around:

| Project | Same idea, industrialized |
| --- | --- |
| Gentoo Prefix | coined "prefix" for exactly this: a source-built tree in a user directory |
| Homebrew / Linuxbrew | per-user package trees outside the distro |
| Spack, EasyBuild | from-source builds of exact versions on HPC clusters where users cannot install packages |
| conda | prebuilt binaries relocated into any prefix at install time |

Spack and EasyBuild are the closest relatives: they also target machines
where the distro will never carry the needed versions. cplx is, in
effect, a hand-rolled, two-machine, air-gapped member of that family.

## Patch-at-install relocation

The finishing technique: the binaries bake the build account's loader
and rpath, and `install_pkg.sh` re-anchors them (patchelf + sed) when
the package is unpacked elsewhere, the pattern conda (prefix
rewriting) and Nix (patchelf) rely on. The full reasoning is in
[Why binaries remember the build home](why-binaries-remember-the-build-home.md).

## What it is not

- **Not cross-compilation.** Build and target are the same machine and
  architecture; only the download happens elsewhere. The sysroot is
  borrowed from the cross world, the rest is not.
- **Not static linking.** The binaries are dynamically linked;
  self-containment comes from carrying the shared libraries along and
  pointing at them via rpath and the baked dynamic linker. That is
  precisely why the relocation issue exists: a static build would not
  remember the build home, but a fully static Python or Git (SSL, NSS,
  locales, loadable modules) is impractical.
- **Not hermetic in the Nix/Bazel sense.** Nix gets relocatability by
  convention with fixed store paths and hashed inputs; cplx bakes real
  home paths and repairs them at install time. Same goal
  (independence from the host system), opposite mechanism.
- **Not containerized.** No Docker or Podman: the target servers offer
  no runtime and no root to add one. The sandbox root gives the
  build-time isolation a container image would, with plain directories
  and `tar`.

## 👉 See also

- [Why recompile at all](why-recompile.md): why the distro packages
  cannot be used in the first place.
- [Anatomy of a build](anatomy-of-a-build.md): the phases the forge
  runs for one tool.
- [The sandbox root](the-sandbox-root.md): how the sysroot is
  assembled from RPMs.
