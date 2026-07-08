# Why recompile at all

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

cplx exists because of a gap that package managers cannot close: the
servers run old enterprise distributions (RHEL 7.9, CentOS 8, RHEL 9.6)
whose official repositories will never carry a recent Git, Python, curl
or OpenSSL — and the machines cannot reach the internet anyway.

## The constraints

- **Frozen repositories.** An enterprise distribution pins tool versions
  for its whole life. Waiting for the distribution to ship Git 2.5x or
  Python 3.13 means waiting forever; the versions cplx targets simply do
  not exist as packages for these systems.
- **No root, no system changes.** Everything installs under a user
  `$HOME`: no `yum install`, no `/usr/local`, no ldconfig. Whatever is
  built must run from a home directory, found through `PATH` and
  `LD_LIBRARY_PATH`, ignoring `/usr/lib` and `/usr/local/lib`.
- **No internet on the servers.** Sources, dependencies, even the
  `-devel` headers needed to compile have to arrive by other means —
  that is the whole [two machines](two-machines-one-build.md) story.
- **Security patches matter.** Staying on the distribution's OpenSSL or
  Git also means staying on their CVEs' timeline. Building current
  releases decouples tool security from server lifecycle.

## The consequence: self-contained builds

Since the system cannot be upgraded and must not be touched, every tool
is built against its own private copy of its dependencies — the
[sandbox root](the-sandbox-root.md) — and wired by rpath and wrappers to
find them at run time. The system's ancient glibc, OpenSSL and gcc stay
exactly where they are; the recompiled tools carry their world with
them. When even the compiler is too old, cplx rebuilds the toolchain
itself (gcc, glibc, make, automake) with the same mechanism.

This is the same philosophy senv applies to portable Windows tools —
no admin rights, nothing global, everything under one folder — pushed
one level deeper: here the "portable archive" has to be compiled first.

## What cplx is not

- Not a package manager: no dependency solver, no signatures, no
  repository metadata. Dependency lists are curated by hand, in order.
- Not a container runtime: no namespaces, no images. The isolation is
  purely conventional — paths, rpaths, wrappers — which is precisely
  why it works on locked-down machines where Docker is not an option.

## 👉 Where to look next

- [Two machines, one build](two-machines-one-build.md) — how the pieces
  reach the offline side.
- [The sandbox root](the-sandbox-root.md) — how self-containment is
  actually achieved.
