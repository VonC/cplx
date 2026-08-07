# The architecture key

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

One string decides which package index, which dependency lists and
which mirrors a build uses. It is computed from the server, not chosen
by you, and it changes when the server is upgraded. This page explains
where it comes from, why it carries a minor version, and what that
costs the day the operating system moves.

## Where the string comes from

The `validate_the_ssh_connection` step asks the server who it is and
keeps the answer:

```bash
ssh "${SSH_CONFIG_ENTRY}" 'source /etc/os-release; printf "%s_%s_%s" $ID $VERSION_ID $(uname -m)'
```

`ID` and `VERSION_ID` come from `/etc/os-release`, the machine type from
`uname -m`, giving `rhel_9.8_x86_64`, `centos_8_x86_64`,
`rhel_7.9_x86_64`. The value is written into `setup.properties` as the
`architecture` property, and everything distribution-specific is keyed
on it from then on.

Two details matter more than they look. The step **recomputes** the
value on every run and overwrites the stored one: the property is a
cache of what the server said, never a setting you own. And the key
carries the **minor** version, because `VERSION_ID` does: `9.8`, not
`9`.

## Why the minor version is in there

Because a distribution's package names and versions are a property of
its release. Between major releases the differences are large enough
that a shared list would be fiction: `rhel_7.9` wants `gdbm-devel`
where `centos_8` wants something else, and the mirror layouts differ
too. Keying on the exact release is the honest default, and it is what
lets one cplx checkout serve several servers at once.

The cost appears within a major release, where the differences are
usually nil. RHEL 9.6 and RHEL 9.8 share an ABI, the same glibc line,
and in practice the same package names; and the mirrors cplx scrapes
for them are the rolling CentOS 9 Stream directories, which are not
tied to any minor at all. Two file sets for one reality.

## What breaks when the server is upgraded

Nothing warns you, because nothing is wrong until the next run. The
server is upgraded from 9.6 to 9.8 by its administrators, the next `s`
re-asks the question, and the stored property flips to
`rhel_9.8_x86_64`. From that moment:

- the per-tool list resolves to `<tool>_rhel_9.8_x86_64.txt`, which
  does not exist, and the copy step ends the run (fatal 902);
- the package index `packages_rhel_9.8_x86_64.txt` does not exist
  either, so nothing could be resolved even if the list were found;
- the mirror property `rhel_9_8_x86_64_pkgs_url` is absent, so the
  index cannot be rebuilt until it is added.

An existing installed tree keeps working: the failure is in the
*supply* chain, not in the built binaries. What stops is the ability to
add a dependency or rebuild a tool, which is exactly when you need it.

The recipe out is
[Survive a server OS upgrade](../how-to/survive-a-server-os-upgrade.md);
the pieces to recreate are listed in
[Package list formats](../reference/package-list-formats.md).

## Why cplx does not simply drop the minor

It could key on the major alone, and lose the ability to describe a
distribution whose minor genuinely differs. It could ignore the server
and let you set the property, and lose the guarantee that the lists
match the machine actually being built on. The direction that keeps
both properties is a **fallback**: resolve the exact key first, and when
no file matches, use the closest available minor of the same major,
saying so out loud. The exact key stays authoritative when it exists,
so a distribution that really diverges can still get its own list.

Until that lands, an upgrade means copying one file set to the new key,
which is why this page exists.

## 👉 Where to look next

- [Survive a server OS upgrade](../how-to/survive-a-server-os-upgrade.md):
  the recovery, step by step.
- [Target a new Linux server](../tutorials/03-target-a-new-linux-server.md):
  creating a key's file set from scratch.
- [Package list formats](../reference/package-list-formats.md): every
  artifact the key names.
- [Two machines, one build](two-machines-one-build.md): why the server
  gets to answer this question at all.
