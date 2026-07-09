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

2. Rebuild the index from scratch:

   ```cmd
   sdpl
   ```

   Each URL is fetched and parsed (three listing formats are recognized);
   all results are merged keeping the latest version per package into
   `src\setups\pkgs\packages_<architecture>.txt`.

3. Interpret the failures:

   | Symptom | Meaning |
   | --- | --- |
   | fatal 113, "less than 50 lines" | the URL answered an error page, not a listing |
   | fatal 112, empty index | no URL produced anything: wrong path or dead vault |
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
