# Target a new Linux server

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

In this tutorial you point cplx at a Linux server it has never seen — a
new host, or a new distribution such as RHEL 9.6 after years of RHEL 7.9 —
and prepare everything a first build needs: the SSH crossing, the package
index for that distribution, and the per-tool dependency lists.

You need SSH connectivity to the new server and a working cplx session.

## 1. Describe the crossing in ~/.ssh/config

```text
Host rhel9
    Hostname new-server.example.corp
    User builder
#rhel9_cd /home/builder/cplx
```

Set `SSH_CONFIG_ENTRY=rhel9` in `senv.local.bat`. The `#rhel9_cd` comment
gives the remote working folder; `setup.sh` stores it as `cplx_path`.

## 2. Let cplx identify the machine

```cmd
st git
s
```

The first step, `validate_the_ssh_connection`, pings the alias and asks
the server who it is (`/etc/os-release` + `uname -m`). The answer becomes
the `architecture` property, for example `rhel_9.6_x86_64`. Everything
distribution-specific is keyed on that string from now on.

## 3. Give the new distribution its mirrors

The package index is built from mirror directory listings. In
`src\setups\setup.properties`, add a comma-separated URL list under the
architecture key (dots become underscores):

```properties
rhel_9_6_x86_64_pkgs_url=https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/,https://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/Packages/
```

Then build the index:

```cmd
sdpl
```

This scrapes each listing, keeps the latest version of every package, and
writes `src\setups\pkgs\packages_rhel_9.6_x86_64.txt`. Mirrors are tried
in order; see
[Add or fix a package mirror](../how-to/add-or-fix-a-package-mirror.md)
when one misbehaves.

## 4. Create the per-tool dependency lists

Each tool needs its list for the new architecture:
`src\setups\pkgs\<tool>\<tool>_rhel_9.6_x86_64.txt`. Start by copying the
list of the closest known distribution (or `minimal_<arch>.txt`), keep the
order, and adjust as the first builds complain. Package names differ
between distributions more often than you would like.

## 5. Set the package suffix

In `senv.local.bat`, set the archive suffix produced on that server:

```bat
set "CPLX_ARCH_EXT=el9.x86_64"
```

Every package built there will be named `<tool>-<version>-<timestamp>.el9.x86_64.tar.gz`.

## 6. Build the first tool

```cmd
sp
i
```

Expect iteration on step 4: a missing header means a missing `-devel`
package in the list. The mapping table in
[Diagnose a failed configure](../how-to/diagnose-a-failed-configure.md)
saves most of the guesswork.

## ✅ Check

`packages_rhel_9.6_x86_64.txt` exists and is thousands of lines long, and
one tool compiles to a `*.el9.x86_64.tar.gz` package.

## 👉 Next steps

- Why the two-machine split exists at all:
  [Two machines, one build](../explanation/two-machines-one-build.md).
- File formats used here:
  [Package list formats](../reference/package-list-formats.md).
