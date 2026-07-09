# The sandbox root

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

Every tool compiles against a private directory, `tools/<tool>/root/`,
that plays the role the operating system normally would: headers in
`root/usr/include`, libraries in `root/usr/lib64`, even the dynamic
linker `ld-linux-x86-64.so.2`. This page explains why it exists and how
it stays honest.

## RPMs without rpm

The server's package database belongs to the system administrators, and
the internet belongs to nobody. So dependencies arrive as raw `.rpm`
files chosen by hand, and `packages_management.sh` unpacks them with
`rpm2cpio | cpio` (or `tar` for cplx-built packages) straight into the
sandbox. No database is touched, no scriptlets run, no signatures are
checked: the trust model is "the Windows side downloaded from mirrors
it chose", the same as for the sources themselves.

Each unpacked package leaves flags next to the sandbox
(`<pkg>.installed`, `<pkg>.list`) so re-runs know what is already there.

## Compiling against the sandbox

The shared `setenv()` points the whole toolchain inward:
`--sysroot=${root}`, `-I${root}/usr/include`, `-L${root}/usr/lib64`,
`PKG_CONFIG_PATH` into the sandbox (with `.pc` files rewritten from
`/usr` to the sandbox by `fix_pkgconfig_pc`), and (the decisive part)
an explicit `-Wl,--dynamic-linker` naming the sandbox's own loader plus
rpaths back into it. The resulting binary does not merely *prefer* the
sandbox: it is wired to it.

## Mirroring: making it self-sufficient

Unpacking an RPM is not enough: its binaries still reference system
libraries. The *mirroring* pass (`mirror_tool_package`) walks each
installed file, runs `ldd`, and copies every system library it still
depends on into the sandbox, recursively, following symlinks. The flag
becomes `<pkg>.installed.mirrored`.

The referee is `check_ldd`: after mirroring, any dependency that still
resolves to an absolute path outside the tools tree (or does not
resolve at all) is fatal. Nothing leaves the forge while it secretly
leans on `/usr/lib64`. (Known noise like the Dynatrace
`liboneagentproc.so` preload is explicitly excluded.)

## One sandbox per tool, on purpose

Sandboxes are not shared: git's `root/` and python's `root/` may contain
different OpenSSL headers. That costs disk and duplicate downloads, and
buys the thing that matters: rebuilding one tool can never break
another, and a tool's dependency list documents exactly what *it* needs.

## 👉 Where to look next

- [Anatomy of a build](anatomy-of-a-build.md): where the sandbox slots
  into the phase sequence.
- [Package list formats](../reference/package-list-formats.md): how the
  sandbox contents are declared.
