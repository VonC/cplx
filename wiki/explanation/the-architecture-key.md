# The architecture key

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

The architecture key identifies the server and its generated package index
and RPM cache. Curated dependency lists and mirror properties can come from
another minor release when an exact definition is absent. These selections
never change the detected key.

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

When connection validation runs, it recomputes and stores the key. A completed
connection step can be skipped, so repeat that step after a server upgrade
before preparing packages. The property records what the server reported;
it is not an override. The key includes the minor version when `VERSION_ID`
does, for example `9.8`.

## How curated metadata is selected

Lists and mirrors are selected independently. Each selection tries the exact
key first, then the highest available lower minor, then the lowest higher
minor. Minor numbers are compared numerically: 10 comes after 9. Candidates
must have the same distribution, major version and complete machine name.
A major-only key such as `centos_8_x86_64` supports exact selection only.

A present empty or comment-only dependency list is an intentional exact
definition. A missing list permits fallback; an unreadable present list fails.
For mirrors, a missing or whitespace-only value permits fallback. Only the
active `setup.properties` is read, and the first occurrence of a duplicate
property wins, including an empty first value. A present unreadable properties
file fails. No eligible definition is an error, not a reason to cross a major
version or distribution boundary.

For example, a RHEL 9.8 server can select
`python_rhel_9.6_x86_64.txt` and `rhel_9_6_x86_64_pkgs_url`. A distinct exact
9.8 list would take precedence without changing mirror selection. Each
substitution is reported. This reuses curated definitions; package availability
and suitability still need verification on the target server.

## What keeps the detected identity

The example still uses `packages_rhel_9.8_x86_64.txt` and the
`pkgs/rhel_9.8_x86_64/` cache. An index from 9.6 is never substituted. A missing
or empty detected index is generated before lookup even when the generation
step is marked done. Either reload flag forces a refresh. Publication replaces
the index only after a complete nonempty candidate is ready; a failed refresh
fails that invocation and preserves the previous index bytes.

Mirror selection happens when generation or an uncached download needs it.
The selected value and ordered URLs stay fixed for that invocation. Failure to
resolve or retrieve an RPM does not trigger another minor selection. The same
selected dependency file is synchronized and copied as `dependencies.list`.

## What changes after a minor upgrade

The tool's package cursor records both the detected key and selected list path.
A changed identity, legacy marker or stale entry restarts from the first active
entry; downloaded RPMs and remote installed flags remain reusable. New progress
is published atomically after each successful synchronization.

Normally `sp` can therefore prepare dependencies after a minor upgrade without
duplicating curated files. Add an exact definition when that release needs a
different list or mirrors. See
[Survive a server OS upgrade](../how-to/survive-a-server-os-upgrade.md) for the
operator checks and [Package list formats](../reference/package-list-formats.md)
for the separate artifacts.

## 👉 Where to look next

- [Survive a server OS upgrade](../how-to/survive-a-server-os-upgrade.md):
  the recovery, step by step.
- [Target a new Linux server](../tutorials/03-target-a-new-linux-server.md):
  creating a key's file set from scratch.
- [Package list formats](../reference/package-list-formats.md): every
  artifact the key names.
- [Two machines, one build](two-machines-one-build.md): why the server
  gets to answer this question at all.
