# The build order

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

The `tools_to_recompile` property is not an alphabetical list: it is a
dependency plan. cplx has no resolver: the order in which tools are
built, and the `_` entries in dependency lists, *are* the dependency
graph, maintained by hand.

## Libraries feed binaries through the shipment

A library build (`CPLX_BIN` empty) ends with `deploy()`: its package
lands in the shared `tools/pkgs/`. From there, any later tool can list
it in its dependencies with the `_` prefix (`_openssl111`, `_curl`,
`_mpdecimal`), and the package installer unpacks that cplx-built
tarball into the consumer's sandbox exactly like an RPM. The timestamp
in the package name (`-20250302.0138.`) is how a built package is
recognized and how "latest" is chosen.

So the chain for a modern Git on RHEL 7.9 reads:

```text
openssl111 → openldap → libunistring → libidn2 → libpsl → curl → git
```

each arrow meaning "package shipped to tools/pkgs, then consumed as a
`_` dependency". Python similarly consumes `_mpdecimal` and an OpenSSL.

## When even the toolchain is a dependency

On old enough systems the system compiler cannot build the targets
(gcc 4.8 meeting C11-era sources). cplx then rebuilds the toolchain
with itself:

- `automake116` first (bootstraps autotools),
- `make4` (whose `make4_setenv` requires automake116 to be present),
- `gcc`, built out-of-tree, then `glibc`, whose `glibc_setenv` swaps
  the freshly built gcc and make into the PATH and carefully *removes*
  the usual rpath flags: the one build that must not link like the
  others, since it produces the loader everything else names.

The bootstrap tools are binaries (`CPLX_BIN=true`), consumed through
their `current/bin` paths by later `*_setenv` hooks rather than through
`tools/pkgs`.

## Order mistakes and how they show

Building a consumer before its `_` dependency fails at package-sync
time ("matched nothing", fatal 301): the timestamped tarball is simply
not in `tools/pkgs` yet. The fix is never to edit the index: build the
missing library, then re-run `sp`.

## 👉 Where to look next

- [Anatomy of a build](anatomy-of-a-build.md): the `deploy` phase and
  `CPLX_BIN`.
- [Package list formats](../reference/package-list-formats.md): the
  `_` and `>` prefixes.
