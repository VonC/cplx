# How to add a system library by hand

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

Goal: a build or a relocated install needs a runtime library that no
mirror carries and no cplx tool produces, while the server already has
it in `/usr/lib64`. Copy that file into the sandbox yourself.

This is the escape hatch of route 2 in
[Where a sandbox file comes from](../explanation/where-a-sandbox-file-comes-from.md).
Prefer a package (`sp`, see
[Add a dependency to a tool](add-a-dependency-to-a-tool.md)) or a
source build whenever either is possible: both are recorded, repeatable
and versioned, while a hand copy is none of the three. A copy also
never helps a *compile*: it brings no header and no unversioned `.so`
linker symlink.

## 📋 Steps

1. Name the missing file exactly, from the error or from `ldd`:

   ```bash
   ldd tools/<tool>/current/bin/<binary> | grep 'not found'
   ```

2. Locate it on the server, and resolve the symlink chain so you copy
   the real file:

   ```bash
   ls -l /usr/lib64/libfoo.so.1
   readlink -f /usr/lib64/libfoo.so.1
   ```

3. Copy the real file into the tool's sandbox, then recreate the
   soname symlink the loader looks for:

   ```bash
   cp -a "$(readlink -f /usr/lib64/libfoo.so.1)" tools/<tool>/root/usr/lib64/
   cd tools/<tool>/root/usr/lib64
   ln -sfn libfoo.so.1.2.3 libfoo.so.1
   ```

4. Record what you did, since nothing else will: no flag file is
   created for a hand copy, and a later `sp` run neither replaces nor
   removes it. Add a comment line in the tool's dependency list:

   ```text
   # libfoo.so.1 copied by hand from /usr/lib64 (no package on the mirrors)
   ```

## ✅ Check

Nothing resolves outside the tools tree any more:

```bash
ldd tools/<tool>/current/bin/<binary> | grep -E '=> /(usr|lib)' 
```

An empty result is the goal; the same rule the automatic mirroring pass
enforces with `check_ldd` (fatal 121, 124 or 199, see
[Exit codes](../reference/exit-codes.md)).

## ⚠️ What a hand copy costs

- it freezes one server's version of the library into your tree, with
  no record of where it came from beyond your comment;
- it will not follow the server when the system package is updated;
- on a foreign distribution the copy stays a stranger: it was linked
  against that server's C library, so ship it only together with the
  matching runtime, and re-check with `ldd` after relocation
  ([Relocate an install to another prefix](relocate-an-install-to-another-prefix.md)).

When any of that starts to hurt, promote the library to a real
dependency: a package line if a mirror carries it, or a cplx tool if
none does.
