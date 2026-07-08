# cplx

<img src="wiki/assets/logo-cplx-transparent.png" alt="cplx logo: download, bridge, forge and shipment around two machines" width="200" align="right">

`cplx` recompiles modern versions of core Linux tools (Git, Python, curl,
OpenSSL, pass, and their toolchain) for offline RHEL/CentOS servers whose
official repositories will never carry them. A Windows PC with internet
access downloads the sources and dependencies; the offline Linux server,
reached over one SSH alias, compiles and packages them as self-contained
builds that live under `$HOME` and ignore the system libraries.

In one line: native, from-source, unprivileged prefix builds against an
RPM-derived sysroot, made relocatable at install time — not
cross-compilation, not static linking, not containers
([What kind of build is this](wiki/explanation/what-kind-of-build-is-this.md)).

Four themes structure the project — and its logos:

- 🌐 **the download**: sources and RPM packages fetched on Windows,
- 🌉 **the bridge**: the checkpointed SSH crossing to the offline server,
- 🔨 **the forge**: the sandboxed compilation against a per-tool root,
- 📦 **the shipment**: timestamped packages, wrappers and deployment.

## One consequence to know: binaries remember the build home

Every compiled tool hard-codes the build account's dynamic linker
(`PT_INTERP`) and library rpath, plus text-form paths (`pyvenv.cfg`,
shebangs, `*.pc`). The result runs unchanged only where
`/home/<builder>` is readable — on any other account or prefix it fails
with a misleading `No such file or directory`, or worse, silently keeps
loading from the build home. Deploying elsewhere therefore goes through
`pkg.sh` + `install_pkg.sh`, which package the live tree and re-anchor
every path (patchelf + sed) at unpack time — the same patch-at-install
pattern conda (prefix rewriting) and Nix (patchelf) rely on. See
[Why binaries remember the build home](wiki/explanation/why-binaries-remember-the-build-home.md)
and
[Relocate an install to another prefix](wiki/how-to/relocate-an-install-to-another-prefix.md).

## Documentation

The [wiki](wiki/README.md) is organized on the
[Diátaxis](https://diataxis.fr/) model. Start with
[Your first recompiled tool](wiki/tutorials/01-your-first-recompiled-tool.md),
or jump to [Commands](wiki/reference/commands.md) and
[Why recompile at all](wiki/explanation/why-recompile.md).

## Quick start

```cmd
cd /d C:\path\to\cplx
senv
st git   &:: pick the tool
s        &:: set up the remote environment and sources
sp       &:: install the build dependencies into the sandbox
i        &:: compile, package, deploy
```

Releases are described in the [CHANGELOG](CHANGELOG.md).
