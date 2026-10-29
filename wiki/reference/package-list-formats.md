# Package list formats

<img src="../assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

The three kinds of files under `src\setups\pkgs\`, and the URL
placeholders they rely on. The architecture key is
`<ID>_<VERSION_ID>_<machine>` from the server's `/etc/os-release`, e.g.
`rhel_9.6_x86_64` (dots become underscores in property keys).

## Everything the architecture key names

The key is recomputed when connection validation runs and is stored in
`setup.properties`; it includes the minor version reported by the server. Generated
indexes and downloaded RPMs retain this detected key, while curated lists and
mirrors may independently select another minor
([The architecture key](../explanation/the-architecture-key.md)).

| Piece | Path or key | Who creates it | Missing means |
| --- | --- | --- | --- |
| architecture property | `architecture` in `src\setups\setup.properties` | `setup.sh`, from the server | fatal 6 |
| mirror URL list | `<arch with underscores>_pkgs_url` property in active properties | you, by hand | absent/trimmed-empty permits eligible minor fallback; no candidate fails 114 when needed |
| package index | `src\setups\pkgs\packages_<detected-arch>.txt` | `sp` or `sdpl`, generated | absent/empty requires generation before lookup despite done markers |
| per-tool list | `src\setups\pkgs\<tool>\<tool>_<selected-arch>.txt` | you, by hand | absent permits eligible minor fallback; no candidate fails 114 |
| seed list | `src\setups\pkgs\minimal_<arch>.txt` | `add_tool.bat` copies it | a new tool starts from an empty list |
| downloaded RPMs | `src\setups\pkgs\<arch>\` | the download step | packages are fetched again |

Curated selection is exact first, then highest lower minor, otherwise lowest
higher minor, compared numerically within the same distribution, major and
whole machine name. Major-only keys support exact selection only. A present
empty/comment-only list is authoritative; unreadable present metadata fails.
Mirror values come only from the active properties, with the first duplicate
key winning. No fallback uses another minor's generated index.

The archive suffix (`CPLX_ARCH_EXT`, for example `el9.x86_64`) is
related but separate: it labels the packages a build produces and lives
in `senv.local.bat`, not in the properties
([CPLX variables](cplx-variables.md)).

## `packages_<architecture>.txt`: the generated index

Built from selected mirror listings; do not edit by hand. One full package
filename per line, sorted by package prefix. The existing aggregation keeps
the last listed entry for each prefix:

```text
binutils-2.35.2-65.el9.x86_64.rpm
zlib-devel-1.2.11-40.el9.x86_64.rpm
```

Packages built by cplx itself appear with a leading `_` and a timestamp:

```text
_openssl111-1.1.1w-20250302.0138.el7.x86_64.tar.gz
```

Either reload flag requests one refresh per invocation. A unique sibling
candidate is published atomically only after successful nonempty generation.
Failed refresh preserves the old index but fails that invocation. A later run
without refresh may reuse the old file. `.cplx-index-*` scratch paths are never
metadata candidates.

## `<tool>\<tool>_<architecture>.txt`: the curated dependency list

Hand-maintained, ordered (dependencies first), copied to the server as
`tools/<tool>/dependencies.list`. One *short* name per line: no version,
no extension; the index resolves it to the exact file (fatal 301 if
nothing matches, 302 if several do).

The same selected source file drives synchronization and the remote copy.
`pkgs/<tool>/last` is a literal four-line progress record:

```text
cplx-package-progress-v1
architecture=rhel_9.8_x86_64
list=src/setups/pkgs/python/python_rhel_9.6_x86_64.txt
last=zlib-devel
```

Only matching architecture/list identity with an active cursor resumes, after
the first matching entry. Legacy, malformed, changed or stale state restarts
with an atomically published empty cursor before work; each successful entry
updates it atomically. Missing/empty cursors start normally. Direct packages
leave this record untouched. `sp reset <entry>` validates and resumes after an
active entry; `sp reset` starts at the beginning.

| Prefix | Meaning |
| --- | --- |
| `#` | comment / disabled line |
| `_` | package built by another cplx tool, taken from the remote `tools/pkgs/`, never downloaded |
| `>` | force reinstall of this line and every following one |

`+` must be escaped: `_gcc-c\+\+`, `_libstdc\+\+-devel`.

`minimal_<architecture>.txt` is the seed list (`glibc-headers`,
`glibc-devel`, `glibc`, `kernel-headers`, `cpp`) copied by `add_tool.bat`
for every new tool.

## Mirror URLs: `<architecture>_pkgs_url` property

Comma-separated list, selected lazily for index generation or an uncached RPM
and pinned for the invocation. URLs are tried in order; the last failure is
fatal, with no selection of another minor.
Placeholders inside a URL:

| Placeholder | Replaced by |
| --- | --- |
| `[l]` | lowercase first letter of the package (Fedora `Packages/<l>/` sharding) |

## Source URLs: `CPLX_URL`

| Placeholder | Replaced by |
| --- | --- |
| `[version]` | the version as-is (`2.52.0`) |
| `[version_]` / `[_version]` | the version with dots turned into underscores (`2_52_0`) |

## Safety nets

- an index page under 50 lines is treated as an error page (fatal 113),
- an existing cached file under 9 KB is rejected and renamed `*._to_delete`;
  a new undersized download is discarded,
- downloads send browser-like headers to pass Cloudflare-protected
  vaults.

## On-server flag files (`tools/<tool>/pkgs/`)

| File | Meaning |
| --- | --- |
| `<pkg>.installed` | unpacked into the sandbox `root/` |
| `<pkg>.installed.mirrored` | plus its system dependencies copied in (self-contained) |
| `<pkg>.list` | file inventory of the archive |

Not every file in a sandbox has a line in these lists: the mirroring
pass copies system libraries in on its own, and a hand copy leaves no
flag at all
([Where a sandbox file comes from](../explanation/where-a-sandbox-file-comes-from.md),
[Add a system library by hand](../how-to/add-a-system-library-by-hand.md)).
