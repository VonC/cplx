# Where a sandbox file comes from

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

A build stops on a missing `sqlite3.h`, or a binary asks for a
`libfoo.so.1` nobody put there. The question is always the same: how
does that file legitimately enter `tools/<tool>/root/`? cplx has
exactly three answers, and picking the right one is most of the work.

## The constraint that shapes all three

You are not an administrator on the target server, and even if you
were, installing or upgrading a system package could break the software
already running there. So no route ever writes outside `~/cplx`: no
`yum`, no `rpm -i`, no `/usr` touched. Everything lands in the tool's
own sandbox, and the compiler is pointed at that sandbox instead of the
system (`--sysroot`, see [The sandbox root](the-sandbox-root.md)).

That last part explains a recurring surprise: a library sitting in the
server's `/usr/lib64` is *not* usable by a cplx build. The sysroot
redirects every header and library lookup into `root/`, on purpose, so
that the result never silently links against a host version. Presence
on the server proves nothing; presence in the sandbox is what counts.

## Route 1: unpack a package payload into the sandbox

The default, and the cheapest. Add the package's short name to
`src\setups\pkgs\<tool>\<tool>_<architecture>.txt`; the Windows side
downloads the `.rpm` from the configured mirrors, ships it, and
`packages_management.sh` unpacks the payload with `rpm2cpio | cpio`
from inside `root/`. It is an unpack, not an installation: no package
database, no scriptlets, nothing outside the sandbox.

Use it whenever the distribution carries an acceptable version. Most of
the sandbox arrives this way: zlib, libffi, ncurses, readline, gdbm,
bzip2, xz, libuuid.

## Route 2: copy what the server already has

The *mirroring* pass does this automatically: after unpacking a
package, it runs `ldd` over the installed files and copies every system
library they still reference into the sandbox, recursively, until
nothing resolves outside the tools tree
([The sandbox root](the-sandbox-root.md)). You rarely invoke this
route; it invokes itself, and `check_ldd` refuses to let a build leave
the forge while it secretly leans on `/usr/lib64`.

Its manual variant, copying a file from `/usr` into the sandbox by
hand, is the escape hatch when no package carries what you need
([Add a system library by hand](../how-to/add-a-system-library-by-hand.md)).
It only ever provides runtime libraries: a `.so.N` exists on a server,
but headers and the unversioned `.so` linker symlink usually do not,
since those ship in `-devel` packages that deployment servers do not
install. A copy can therefore satisfy a *load*, never a *compile*.

## Route 3: build the library as a cplx tool

The expensive route, reserved for what the distribution cannot provide
acceptably: a version too old for the software you actually want, or a
component you refuse to leave on the distribution's patch cycle. The
library becomes a tool like any other (its own entry, version, source
URL and install functions), and consumers reference its output with the
`_` prefix in their dependency list, which is also what fixes the build
order ([The build order](the-build-order.md)).

This is why OpenSSL, mpdecimal, git and Python are cplx tools, while
zlib and ncurses are not.

## Choosing

| Question | If yes |
| --- | --- |
| Does the build need headers or a linker symlink? | Route 1 or 3 (route 2 cannot compile) |
| Does the distribution carry a version good enough? | Route 1 |
| Is the version too old, or the patch cycle unacceptable? | Route 3 |
| Is it only a runtime library, absent from every mirror? | Route 2, by hand |

A worked example: Python's `sqlite3` module. The deployment server has
`libsqlite3.so.0`, so route 2 looks tempting, but it carries no
`sqlite3.h`, so it cannot build the extension. The distribution's
sqlite is recent enough for what CPython requires, so route 3 would buy
nothing for a large cost. Route 1 wins: two short names
(`sqlite-libs`, `sqlite-devel`) in Python's dependency list.

Whichever route fills the sandbox, the file must also reach the
*shipped* archive when the deployment target or another machine needs
it at run time: see
[Why binaries remember the build home](why-binaries-remember-the-build-home.md)
and [Packaging and relocation tools](../reference/relocation-tools.md).

## 👉 Where to look next

- [The sandbox root](the-sandbox-root.md): what the sandbox is and how
  it stays honest.
- [Add a dependency to a tool](../how-to/add-a-dependency-to-a-tool.md):
  route 1, step by step.
- [Add a new tool to cplx](../tutorials/02-add-a-new-tool.md): route 3,
  taught end to end.
