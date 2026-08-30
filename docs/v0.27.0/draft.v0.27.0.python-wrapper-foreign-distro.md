# Keep the python wrapper working on a foreign distribution

- Type: issue
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md

## The split entry this draft derives from

Umbrella item 3, slug `python-wrapper-foreign-distro`, type Issue. It regroups
work item 1 (Q20) and decision D2. Depends on nothing.

Placed third because it is independent of both the installer and the build, and
its acceptance needs only a redeployed env tree.

## The defect, as the umbrella records it

| Q | Defect | Evidence | Interim in the pipeline |
| --- | --- | --- | --- |
| Q20 | The python wrapper exports `LD_LIBRARY_PATH` then calls host `readlink`/`mv`/`ln`, which bind the shipped RHEL libc and die on `GLIBC_PRIVATE` | develop#3, wrapper line 60 mangled exec target | uv drives the `python3*_bin` ELF directly via `UV_PYTHON` |

## Work item 1 (Q20): harden the python wrapper against foreign coreutils

Files: `src/install/env/python/bin/python` (the wrapper deployed as
`tools/python/bin/python`, reached through the
`tools/python/current/bin/python3` symlink) and
`src/install/env/python/bin/setenv` (line 15 exports `LD_LIBRARY_PATH`
toward `root/usr/lib64` and the shipped library directories).

Mechanism: the wrapper sources `setenv` at line 18, then performs its
first-run surgery (lines 30 to 56: `readlink` on the `python3` symlink,
`mv` of the real binary to `<name>_bin`, `ln` of the wrapper in its
place) and its venv post-processing (lines 65 to 89: `readlink`, `ln`,
`cp`, `sed`, `grep`). With `LD_LIBRARY_PATH` already exported, every
one of those host binaries loads the shipped RHEL libc. On RHEL host
tools and shipped libraries are ABI-compatible, so nothing shows; on
Debian they die on `undefined symbol: _dl_readonly_area, version
GLIBC_PRIVATE`, `readlink` answers empty, and the wrapper computes a
mangled exec target.

Fix direction (keeps `setenv` unchanged for interactive operators):

- in the wrapper, right after sourcing `setenv`, save then unset
  `LD_LIBRARY_PATH`;
- run all helper commands (both the first-run surgery and the venv
  post-processing) without it;
- restore it only on the final interpreter call (lines 59 to 63), where
  the patched ELF needs the shipped libraries for itself and for the
  wheel extensions it will dlopen.

Alternatives, kept for the record: `env -u LD_LIBRARY_PATH <cmd>` on
each helper call, or bash builtins where they exist. The save/unset/
restore form touches one place instead of every call site, which is why
it is preferred.

Acceptance for this item: on a Debian 12 container, a fresh relocation
followed by `tools/python/current/bin/python3 --version` answers the
toolchain version through the wrapper, first call included (the
first-run surgery is the code path that died). Behavior on the RHEL
build account and targets is unchanged.

## Decision D2, which this item implements

| Decision | Options | Resolved |
| --- | --- | --- |
| Wrapper strategy for `LD_LIBRARY_PATH` | (a) save/unset around helpers, restore on the exec; (b) `env -u` per call site; (c) builtins where possible | (a) |

## What this draft does not cover

The umbrella assigns elsewhere, and this item must not absorb:

- the relocation pass and `DT_RPATH`, item 2, now completed. This item changes
  no ELF and reads no tag;
- the runtime closure, item 4. Whether the shipped tree CONTAINS the right
  libraries is a different question from which processes are pointed at them;
- the sqlite build, item 6, and the archive rebuild, item 7.

## Reading of the current wrapper, taken from the file

Counted by reading `src/install/env/python/bin/python` rather than estimated.
After `source "${DIR}/setenv"` at line 18 the wrapper makes FOURTEEN host-tool
invocations and TWO interpreter invocations, at lines 60 and 62. The interpreter
pair is what genuinely needs the exported path; the fourteen are what must run
without it.

Two observations that belong to the requirement rather than to this draft, and
are recorded so they are not lost:

- the Debian failure MANGLES rather than aborts. `readlink` returns empty, the
  comparison at line 32 finds the empty value different from the expected
  symlink target, and the surgery then builds `mv` and `ln` paths from an empty
  string. The wrapper cannot tell "there is no symlink" from "the tool that
  reads symlinks died";
- two incidental defects sit in the same files and are out of scope: an
  unconditional debug `echo` to stderr on every invocation at line 14, and
  `setenv` line 18 exporting `CPLUS_INCLUDE_PATH` to a path under a developer's
  home that exists on no deployment target.
