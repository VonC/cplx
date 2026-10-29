# How to add or fix a package mirror

<img src="../assets/logo-cplx-download-transparent.png" alt="" height="90" align="right">

Goal: the package index fails to build, or a download comes back broken;
point cplx at a working mirror for the target distribution.

The index for an architecture is scraped from plain directory listings.
Old distributions live on vaults and archives that move, throttle, or hide
behind Cloudflare; cplx therefore accepts several mirrors and tries them
in order.

## 📋 Steps

1. Edit the architecture's URL list in `src\setups\setup.properties`
   (comma-separated, dots of the version become underscores in the key):

   ```properties
   rhel_7_9_x86_64_pkgs_url=https://vault.centos.org/7.9.2009/os/x86_64/Packages/,https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/[l]/
   ```

   `[l]` is replaced by the lowercase first letter of each package: the
   Fedora archive shards its `Packages/` folder that way. The template
   `setup.tpl.properties` keeps commented alternatives for each distro.

   Use the selected property reported by setup. Selection tries the exact
   key, highest lower minor, then lowest higher minor of the same distribution,
   major and machine. Missing or whitespace-only values allow fallback; the
   first occurrence of a duplicate key wins. Only this active properties file
   participates: editing the template does not change an existing local file.
   Dependency-list selection is independent of mirror selection.

2. Rebuild the index from scratch:

   ```cmd
   sdpl
   ```

   Each URL is fetched and parsed; the established package-name aggregation
   writes `src\setups\pkgs\packages_<detected-architecture>.txt`. An index
   from the selected mirror's minor is never substituted. Normal `sp` also
   generates a missing or empty detected index despite a done marker. Either
   `CPLX_RELOAD_PACKAGES` or `CPLX_FORCE_RELOAD_PACKAGES` forces a refresh.

   The complete nonempty result replaces the old index atomically. A failed
   refresh preserves its bytes but fails this invocation; a later run without
   a refresh request can reuse it. Mirror URLs are selected once when needed
   and tried in order for an uncached RPM. Retrieval failure is terminal;
   setup does not select another minor to hide it.

3. Interpret the failures:

   | Symptom | Meaning |
   | --- | --- |
   | fatal 113, "less than 50 lines" | the URL answered an error page, not a listing |
   | fatal 112, empty index | no URL produced anything: wrong path or dead vault |
   | fatal 111, index processing | listing extraction or aggregation failed |
   | fatal 114, metadata selection | no eligible nonempty mirror value, or unreadable metadata |
   | fatal 115, index publication | scratch/candidate creation, writing or atomic replacement failed |
   | `*.rpm._to_delete` files in `pkgs\<arch>\` | download under 9 KB: an HTML page saved as an RPM |
   | HTTP 403 on a vault | Cloudflare; cplx already sends browser-like headers, try another mirror first in the list |
   | fatal 302, several matches | the package short name is ambiguous in the index, make the list entry more precise |

4. For a single stubborn package, bypass the full list run:

   ```cmd
   sp p_zlib-devel
   ```

## ✅ Check

`packages_<architecture>.txt` is regenerated (thousands of lines), and
the package that failed now downloads into `src\setups\pkgs\<arch>\` with
a plausible size.

Related: [Package list formats](../reference/package-list-formats.md);
the mirror-hunting notebook is `src/setups/doc/package_list_urls.md`.
