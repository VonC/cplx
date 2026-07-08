# Package list formats

<img src="../assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

The three kinds of files under `src\setups\pkgs\`, and the URL
placeholders they rely on. The architecture key is
`<ID>_<VERSION_ID>_<machine>` from the server's `/etc/os-release`, e.g.
`rhel_9.6_x86_64` (dots become underscores in property keys).

## `packages_<architecture>.txt` — the generated index

Built by `sdpl` from the mirror listings; do not edit by hand. One full
package filename per line, latest version only, alphabetical:

```text
binutils-2.35.2-65.el9.x86_64.rpm
zlib-devel-1.2.11-40.el9.x86_64.rpm
```

Packages built by cplx itself appear with a leading `_` and a timestamp:

```text
_openssl111-1.1.1w-20250302.0138.el7.x86_64.tar.gz
```

## `<tool>\<tool>_<architecture>.txt` — the curated dependency list

Hand-maintained, ordered (dependencies first), copied to the server as
`tools/<tool>/dependencies.list`. One *short* name per line — no version,
no extension; the index resolves it to the exact file (fatal 301 if
nothing matches, 302 if several do).

| Prefix | Meaning |
| --- | --- |
| `#` | comment / disabled line |
| `_` | package built by another cplx tool, taken from the remote `tools/pkgs/`, never downloaded |
| `>` | force reinstall of this line and every following one |

`+` must be escaped: `_gcc-c\+\+`, `_libstdc\+\+-devel`.

`minimal_<architecture>.txt` is the seed list (`glibc-headers`,
`glibc-devel`, `glibc`, `kernel-headers`, `cpp`) copied by `add_tool.bat`
for every new tool.

## Mirror URLs — `<architecture>_pkgs_url` property

Comma-separated list, tried in order; the last failure is fatal.
Placeholders inside a URL:

| Placeholder | Replaced by |
| --- | --- |
| `[l]` | lowercase first letter of the package (Fedora `Packages/<l>/` sharding) |

## Source URLs — `CPLX_URL`

| Placeholder | Replaced by |
| --- | --- |
| `[version]` | the version as-is (`2.52.0`) |
| `[version_]` / `[_version]` | the version with dots turned into underscores (`2_52_0`) |

## Safety nets

- an index page under 50 lines is treated as an error page (fatal 113),
- any download under 9 KB is rejected and renamed `*._to_delete`,
- downloads send browser-like headers to pass Cloudflare-protected
  vaults.

## On-server flag files (`tools/<tool>/pkgs/`)

| File | Meaning |
| --- | --- |
| `<pkg>.installed` | unpacked into the sandbox `root/` |
| `<pkg>.installed.mirrored` | plus its system dependencies copied in (self-contained) |
| `<pkg>.list` | file inventory of the archive |
