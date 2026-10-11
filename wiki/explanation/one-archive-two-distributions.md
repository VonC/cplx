# One archive, two distributions

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

_Why a toolchain built natively on RHEL can serve a Debian CI agent as
well, why nothing that broke there broke the relocation itself, and why
the RHEL side could never have revealed any of it._

## The build model does not change

cplx compiles on RHEL 9, against sandbox RPMs, and relocates at install
time: `install_pkg.sh` re-anchors every interpreter, search path and text
path into whatever prefix it is given
([Why binaries remember the build home](why-binaries-remember-the-build-home.md)).
The same `tools` archive serves two kinds of hosts:

| | RHEL 9 deployment servers | Debian 12 CI agent |
| --- | --- | --- |
| userland | the build's own distribution, glibc 2.34 family | throwaway containers, glibc 2.36 |
| host libraries | ABI-compatible with the shipped ones | newer, built against a newer libc |
| host tools | the full set the installer needs, rsync included | the same set, without rsync |
| what runs there | the deployed application | relocation, tests and packaging of a consumer application |

There is no second archive and no cross-distribution build. The contract
that matters held on the agent: once the installer's patchelf pass had
re-anchored interpreters and search paths, the toolchain's git and its
Python ELF started and ran.

## Failures live in the margins of the contract

Every defect the agent exposed sat next to the relocation, not inside it:

| Margin | How it showed on the agent | What cplx changed |
| --- | --- | --- |
| a wrapper calling host tools | the Python wrapper exported the shipped library path, then ran host `readlink`, `mv`, `ln`; they bound the shipped libc, died on `GLIBC_PRIVATE`, and the wrapper built a mangled path | the path is scoped to the interpreter call, and an empty `readlink` stops the wrapper ([Python wrapper](../reference/python-wrapper.md)) |
| a host tool assumed present | no rsync, so the installer stopped at its mirror step | a `cp` fallback, stricter than rsync on a wrong-shaped destination ([Packaging and relocation tools](../reference/relocation-tools.md)) |
| a missing module | `_sqlite3` had never been compiled, and `libsqlite3.so.0` shipped nowhere | sandbox payloads, explicit configure inputs, a capability probe and a closure floor ([Check Python SQLite capability](../how-to/check-python-sqlite-capability.md)) |
| library resolution | lookups fell back to the host cache: shipped libraries had no search path of their own, and the interpreter's `DT_RUNPATH` did not reach the libraries a wheel pulls in | `DT_RPATH` on every shipped library, a packaging gate refusing an archive that does not resolve inside itself ([Runtime closure checker](../reference/toolchain-runtime-closure.md)), and a consumer runtime setup for wheels carrying their own `DT_RUNPATH` |

Fixing the margins is what makes the archive distribution-agnostic. The
alternative, a RHEL-flavored agent image, was rejected for exactly that
reason: it would have made the agent resemble the build host instead of
making the archive independent of the host that runs it.

## Why the RHEL side could not see any of it

On RHEL the shipped libc and the host libc belong to the same family. A
lookup that escapes the prefix lands on a compatible host copy and the
process carries on. The escape is real; it just costs nothing. On the agent
the same escape lands on a library that demands version nodes the shipped
libc never defined (`GLIBC_2.36 not found`), and the process dies.

The RHEL servers are also the *less* isolated side. They inject a
monitoring library into every process through the system preload, so a
host-built object already lives inside the relocated toolchain's processes
there. It works, and it limits how far the shipped glibc may drift from
the servers'.

Two rules follow:

- **a pass on RHEL proves no regression, never a fix.** A wrapper fix, a
  closure fix or a search-path fix for a foreign-distribution defect is
  invisible by construction where the defect cannot fire;
- **a pass on the agent needs a control.** The run that shows the fix works
  also runs the reverted fix and shows it failing, or the pass cannot be
  told apart from a host where the defect never fired
  ([Validate a change on a foreign CI agent](../how-to/validate-a-change-on-a-foreign-ci-agent.md)).

## Evidence is a listing and a trace, and both must have looked

Two readings answer two different questions, and acceptance needs both:

- the **listing**, static: the shipped loader resolving every shipped ELF
  and every venv wheel, and the closure checker over the declared scope.
  It says what each object *would* bind. Probed one by one, a shipped
  library is a root object with no ancestor search path, so the listing
  overstates: one measurement flagged 110 of 388 objects, every one a
  shipped library probed alone and none a wheel, while the running process
  bound nothing from the host. Read the whole search path before concluding
  that something is missing;
- the **trace**, live: `LD_DEBUG=libs,versions` on the process that really
  imports the heavy wheels. It says what *was* bound.

Each reading must also prove it observed something. A trace that
inventoried no process once reported "no host library loaded", a true
sentence about an empty observation. So the trace names the process it
followed and how many trace files it kept, and an empty inventory is
inconclusive. The same rule runs through the whole gate: an empty
observation is never a pass
([Why the archive declares its own scope](why-the-archive-declares-its-own-scope.md#an-empty-observation-is-never-a-pass)).

The application's venv eventually stopped travelling inside an archive at
all; [Lock-identical, not byte-identical](lock-identical-not-byte-identical.md)
explains what replaced it.

## 👉 See also

- [Two machines, one build](two-machines-one-build.md): the build side of
  the same story.
- [Why binaries remember the build home](why-binaries-remember-the-build-home.md):
  the relocation contract that held.
- [Rebuild and publish the tools archive](../how-to/rebuild-and-publish-the-tools-archive.md):
  how one archive is qualified on both distributions.
