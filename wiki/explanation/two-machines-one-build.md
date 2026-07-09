# Two machines, one build

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

Every cplx build is a collaboration between a Windows PC that can reach
the internet and a Linux server that cannot. This page explains the
division of labor and the single, narrow channel between them.

## Who does what

| | Windows PC | Linux server |
| --- | --- | --- |
| has | internet (through the corporate proxy), the repository, the session | the target OS, the CPU that must run the result |
| does | download sources and RPMs, curate lists, orchestrate | extract, configure, compile, package |
| never does | compile anything | download anything |

The split is not a preference but a constraint: only the Windows side
has network access, and only the Linux side produces binaries that are
valid for the target (same kernel, same arch, and (once mirrored into
the sandbox) the right old glibc to link against).

## One alias, one folder, one comment

The entire bridge is a single SSH alias (`SSH_CONFIG_ENTRY`) declared in
`~/.ssh/config`, plus one unusual convention: the remote working folder
is written *as a comment* in that same file (`#<alias>_cd ~/cplx`),
because ssh_config has no user-defined fields. `setup.sh` parses the
comment, and everything else derives from it (`cplx_path`).

Traffic over the bridge is deliberately boring:

- scripts and environment go over as `tar | ssh "tar x"` streams,
- source archives and RPMs go over as `scp`, skipped when already there,
- commands run as one-shot `ssh <alias> "cd ...; bash ..."` calls whose
  last output line is the remote exit status,
- results come *back* too: the build log after every run, and
  `config.log` when configure fails; the server is headless, all
  reading happens in VS Code on Windows.

## Identity of the machine, not of the human

The first crossing asks the server who it is (`/etc/os-release` +
`uname -m`) and freezes the answer as the `architecture` property
(`rhel_9.6_x86_64`). From then on, every distribution-specific artifact
(package index, dependency lists, package suffix (`el9.x86_64`)) is
keyed by that string. Pointing `SSH_CONFIG_ENTRY` at a different server
is all it takes to build for another distribution
([Target a new Linux server](../tutorials/03-target-a-new-linux-server.md)).

## Why not just mirror a repository?

Mirroring yum repositories offline would bring thousands of packages,
GPG chains and repo metadata for the *old* versions only; the new
versions still would not exist. cplx inverts the approach: bring the
minimum (one source archive, a curated handful of RPMs for headers and
build deps) and spend the effort on the compile side instead.

## 👉 Where to look next

- [Checkpoints and resume](checkpoints-and-resume.md): why crossing the
  bridge twice never redoes work.
- [Anatomy of a build](anatomy-of-a-build.md): what happens once the
  material is on the other side.
