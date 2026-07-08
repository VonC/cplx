# cplx

<img src="wiki/assets/logo-cplx-transparent.png" alt="cplx logo: download, bridge, forge and shipment around two machines" width="200" align="right">

`cplx` recompiles modern versions of core Linux tools (Git, Python, curl,
OpenSSL, pass, and their toolchain) for offline RHEL/CentOS servers whose
official repositories will never carry them. A Windows PC with internet
access downloads the sources and dependencies; the offline Linux server,
reached over one SSH alias, compiles and packages them as self-contained
builds that live under `$HOME` and ignore the system libraries.

Four themes structure the project — and its logos:

- 🌐 **the download**: sources and RPM packages fetched on Windows,
- 🌉 **the bridge**: the checkpointed SSH crossing to the offline server,
- 🔨 **the forge**: the sandboxed compilation against a per-tool root,
- 📦 **the shipment**: timestamped packages, wrappers and deployment.

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
