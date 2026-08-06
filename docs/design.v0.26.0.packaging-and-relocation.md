# Design v0.26.0: canonical packaging and relocation in cplx

Effort record for the 0.26.0 cycle, written when the cycle closed, so the
release carries the design intent behind its commits (`v0.25.0..HEAD`).

## Problem addressed by the 0.26.0 cycle

Every tool cplx compiles hard-codes the build account's dynamic linker
(`PT_INTERP`), library rpath and text-form prefixes, so a package only ran
where `/home/<builder>` was readable. The cure (package the live tree, then
re-anchor every path at unpack time) existed only as project-specific
scripts in the consuming my-project repository, proven on its servers but
invisible to cplx, which creates the problem. Any other consumer of a cplx
package would have had to rediscover the fix.

At the same time, the toolchain itself was aging (Git and Python versions),
and the project had no public front page or structured documentation to
explain what kind of build cplx produces.

## Goals of the 0.26.0 cycle

- Ship the canonical, generalized packaging and relocation tools inside
  cplx, so every tools archive carries its own installer.
- Let a consuming project extend packaging without forking the shared
  logic.
- Refresh the toolchain versions (Git 2.51.0, Python 3.13.7) and harden
  the environment scripts around them.
- Document the project: a Diataxis wiki, a README front page, and the
  branding assets.

## Delivered design, by theme

### Packaging and relocation become cplx canon

`src/setups/env/bin/pkg.sh` archives any `$HOME` folder into `~/pkgs` with
a deterministic tar (sorted names, no gzip timestamp), SHA1 dedup against
the newest archive, and a `<target>.latest.tar.gz` symlink.
`src/setups/env/bin/install_pkg.sh` unpacks the newest matching archive
into any `--prefix` and re-anchors symlinks, text paths
(placeholder-shielded sed), `__pycache__` and ELF interpreter/rpath
(patchelf) there. Both resolve echos from `./` or `../echos` with a
plain-echo fallback, so the installer runs standalone next to an archive
on a foreign account. The existing promotion flow ships them to
`~/cplx/bin` at setup time and `~/tools/bin` at promotion time, so the
tools archive is self-installing.

Robustness follow-ups delivered in the same cycle: the installer deploys
any archive root file (not only `.env`/`.env_`), survives its own
relocation text pass, handles multiple source archives gracefully, and a
`compare_file.sh` helper diffs a deployed file against its cplx source.

### Extension point instead of forks

`pkg.sh` gains a repeatable `--add <item>` for extra top-level archive
items and a `--` sentinel passing everything after it to tar verbatim. A
thin `bin/pkg` dispatcher keeps the historical `pkg <target>` command
working by routing to a `pkg_<target>` overlay found next to it, falling
back to the sibling `pkg.sh`. `bin/pkg_tools.sh` packages the toolchain in
one command. A consuming project now carries only its overlay
(`pkg_<target>`) instead of a fork of the shared logic.

### Toolchain refresh and environment hardening

The senv toolchain moves to Git 2.51.0 and Python 3.13.7. The Python
environment setup is standardized (pip command, venv paths) and made more
robust; `switchtool` forces the environment update after a tool change;
`senv` no longer dies when `CPLX_TOOL` is unset; an rsync helper syncs
tool versions robustly. On the certs side, prompts go through a pinentry
wrapper and the git credential helper is documented.

### Documentation and branding for the project

A Diataxis wiki (`wiki/`: explanation, tutorials, how-to, reference)
documents the build model ("what kind of build cplx does"), packaging and
relocation, the pkg extension and dispatcher, and the git credential
helper. The README becomes a front page with the project logos, and
markdownlint settles the writing rules.

## Out of scope, deferred past 0.26.0

The foreign-distribution compatibility work (running the relocated
toolchain on a Debian CI agent while still deploying to the RHEL targets:
wrapper hardening, sqlite in the toolchain python, glibc companion stubs,
an rsync-free installer fallback) is a separate effort, drafted for the
next cycle.
