# Keep the python wrapper working on a foreign distribution

- Type: issue
- Version: v0.27.0
- Slug: `python-wrapper-foreign-distro`
- Umbrella: [docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md)
- Draft: [docs/v0.27.0/draft.v0.27.0.python-wrapper-foreign-distro.md](draft.v0.27.0.python-wrapper-foreign-distro.md)

Umbrella item 3. Regroups work item 1 (Q20) and decision D2. Depends on
nothing, and nothing in this issue depends on the installer, the relocation
pass, or the archive rebuild.

## What Q20 blocks today

The wrapper was written for a RHEL host running a RHEL-built toolchain, where
the shipped libraries and the host's own tools come from the same distribution
and the same glibc. Nothing in it names a distribution, and nothing had to,
until the CI agent became Debian 12 while the archive stayed RHEL 9. The
guarantee was implicit in a coincidence, and the coincidence ended.

## CDC revision history for the python wrapper

No CDC revision asked for a foreign-distribution guarantee. Earlier CDC state:
the archive has one consumer, RHEL servers whose host libraries are compatible
with the shipped ones, so a wrapper that exports the shipped search path before
calling host tools works by accident. Newer CDC state, v0.27.0: the same
archive must relocate onto a distribution whose libraries are not
interchangeable with the shipped ones, which turns that accident into a defect.

The umbrella settles the direction as decision D2, resolved on evidence rather
than preference: save and unset `LD_LIBRARY_PATH` around the helpers and
restore it on the exec, against `env -u` per call site or bash builtins where
they exist.

## Current behavior in v0.27.0

`src/install/env/python/bin/python` is the entry point every caller reaches,
because the first-run surgery replaces `current/bin/python3` with a symlink
back to it. It does three things in one file:

1. resolves its own directory and sources `bin/setenv` at line 18;
2. performs FIRST-RUN SURGERY, moving the real interpreter aside to
   `python3.13_bin` and leaving symlinks in its place, so later calls come back
   through the wrapper;
3. calls the interpreter, then post-processes a virtualenv when `-m venv` was
   requested.

`bin/setenv` line 15 exports `LD_LIBRARY_PATH` naming eight directories inside
the shipped tree, `root/usr/lib64` first. That export is correct and necessary
FOR THE INTERPRETER, which needs those directories for itself and for every
extension module it will `dlopen`.

The problem is that the export is in force for everything the wrapper does
afterwards, and what it does afterwards is call host tools.

## Current side effects in v0.27.0 for the wrapper

MEASURED IN THIS REPOSITORY, by reading the file rather than by running it:
after `source "${DIR}/setenv"` at line 18 the wrapper makes **fourteen
host-tool invocations** before it is finished, and **two interpreter
invocations** that genuinely need the exported path.

| Line | Call | Needs `LD_LIBRARY_PATH` |
| --- | --- | --- |
| 30 | `readlink` on `current/bin/python3` | no |
| 34 | `mv` the real interpreter aside | no |
| 37, 40, 43 | `ln -nfs`, three times | no |
| 47 | `readlink` on `current/bin/python3_target` | no |
| 52, 55 | `ln -nfs` for `pip` and `pip3` | no |
| 60 | the interpreter, ordinary case | **yes** |
| 62 | the interpreter, virtualenv case | **yes** |
| 66 | `readlink` in the venv | no |
| 69 | `ln -nfs` in the venv | no |
| 72 | `cp` the interpreter into the venv | no |
| 75 | `sed -i` over the venv `pip*` | no |
| 87 | `sed -i` over a `_bin_bin` file | no |
| 89 | `grep -l` over the venv `bin/` | no |

On RHEL none of this shows: the host tools and the shipped libraries are
ABI-compatible, so a host `readlink` resolving against the shipped glibc
behaves exactly as it would against its own.

ON DEBIAN THEY DO NOT. Recorded by the umbrella from the develop#3
investigation, not re-measured here: the host tools die on

```text
undefined symbol: _dl_readonly_area, version GLIBC_PRIVATE
```

THE FAILURE MANGLES RATHER THAN ABORTS, and that is the part worth stating
precisely. `readlink` then returns EMPTY. Line 30 assigns an empty
`python3_target`, line 32 compares it against `../../bin/python`, finds them
different, and the surgery proceeds on paths built from nothing: an `mv` of
`${DIR}/current/bin/` to `${DIR}/current/bin/_bin` and three symlinks whose
names are wrong. The wrapper cannot tell "there is no symlink" from "the tool
that reads symlinks died", and on a foreign host it took the second for the
first.

## CDC wording and gap analysis for the wrapper

The CDC says the toolchain must run on the agent. It does not say which
distribution the agent runs, and the archive is explicitly built elsewhere, so
"the shipped libraries serve the shipped interpreter" is the only reading that
survives a foreign host. The wrapper currently reads it as "the shipped
libraries serve everything this script touches", which is a stronger claim the
CDC never made and which is false the moment the host is not RHEL.

The gap is one of SCOPE, not of content. Nothing about the exported value is
wrong. The set of processes it applies to is wrong.

## Confirmed rule for `python-wrapper-foreign-distro`

Decision D2, restated as the rule this issue implements:

- the wrapper SAVES `LD_LIBRARY_PATH` immediately after sourcing `setenv`, and
  UNSETS it;
- every host-tool invocation in the wrapper runs with it unset, so each
  resolves against the host's own libraries, which is the only set guaranteed
  to match the host's own binaries;
- the saved value is RESTORED only for the interpreter invocation, at both of
  its call sites, because the interpreter and its `dlopen`ed extensions are
  exactly what the shipped libraries exist to serve;
- `bin/setenv` is NOT modified. It remains what an interactive operator sources
  to get a working shell against the shipped tree, and changing it would change
  a contract this issue has no reason to touch;
- the wrapper FAILS CLOSED on an unusable helper result. An empty `readlink`
  answer stops the surgery with a nameable error instead of building paths from
  an empty string.

The last rule is not in D2 and is added here, because the measured failure mode
is a mangled tree rather than an error. A wrapper that cannot distinguish "no
symlink" from "the tool that reads symlinks died" will produce the same damage
the next time a host tool is unavailable for any other reason, and the fix for
the scope defect does not by itself close that.

## Gap to close in the implementation for the wrapper

1. save and unset after the source, in ONE place, so no later edit can add a
   helper call that silently inherits the export;
2. restore around both interpreter call sites, and only those, including the
   virtualenv branch, which is a different binary at a different path;
3. stop on an empty or unusable helper result rather than deriving paths from
   it.

## Concrete examples for the wrapper

- first call on a Debian agent, before the fix: `readlink` returns empty, the
  surgery renames `current/bin/` to `current/bin/_bin` and plants three
  symlinks with empty-derived names; the interpreter is then unreachable by any
  path the wrapper knows;
- first call on a Debian agent, after the fix: the helpers run against the host
  glibc and answer normally, the surgery renames `python3.13` to
  `python3.13_bin`, and the interpreter runs with the shipped path restored and
  answers its version;
- first call on RHEL, after the fix: unchanged in every observable, since the
  helpers resolved correctly against either library set;
- an operator sourcing `setenv` in an interactive shell: unchanged, because
  `setenv` is not modified;
- a helper made to fail deliberately, on any host: the wrapper stops with a
  nameable error and leaves the tree unmodified.

## Code references for the wrapper

- `src/install/env/python/bin/python`, the whole file. Line 18 sources
  `setenv`; lines 30 to 89 hold the fourteen host-tool invocations; lines 60
  and 62 hold the two interpreter invocations.
- `src/install/env/python/bin/setenv`, line 15, the `LD_LIBRARY_PATH` export.
  Read by this issue, not modified by it.

## Acceptance for `python-wrapper-foreign-distro`

This acceptance is stated in TWO PARTS, and the split is deliberate. Umbrella
item 2 was written with criteria it could not discharge, gated itself on
another item's artifact, and cost nine review rounds before the cause was
named. This issue names the same boundary before the work starts.

### What this requirement proves, and can prove today

- `LD_LIBRARY_PATH` is observably UNSET for at least one helper invocation and
  observably SET for the interpreter invocation, measured from the wrapper's
  own run rather than asserted from the source;
- with a helper made to fail deliberately, the wrapper STOPS with a nameable
  error and leaves the tree unmodified. A control that plants the failure is
  required, since the whole issue is that a silent tool failure was read as a
  valid answer. This is provable on any host, because it needs only a helper
  that fails, not a foreign glibc;
- after a first call the tree is in the expected shape: `python3` is a symlink
  to the wrapper, `python3.13_bin` is the real interpreter, `python3_target`
  points at it, and no path in the tree is derived from an empty string;
- `bin/setenv` is byte-identical to its pre-change content;
- BEHAVIOR ON RHEL IS UNCHANGED: a first call on the RHEL build account and on
  a RHEL target answers the toolchain version through the wrapper. This is the
  no-regression half the umbrella names, and the RHEL target is the only place
  it can be checked.

### What this requirement proves on Debian, and what stays owed

An earlier revision of this section handed the Debian first call to umbrella
item 7 outright, on the reading that this requirement had no Debian environment
in reach. That reading was correct when it was written and is no longer: the CI
agent IS the Debian 12 host, and it is reachable again.

So the Debian first call is a criterion of THIS requirement, not an obligation
passed on. It runs on the CI agent against the archive as published today, and
it runs WITH A CONTROL: the same call with the fix reverted must mangle the
tree. Without that control an A8 pass cannot be told apart from a pass on a host
where the defect never fired, which is exactly what a RHEL run yields.

That control matters more here than it usually would. The defect is invisible on
RHEL BY CONSTRUCTION, so every green this requirement can produce outside Debian
is uninformative about the fix. A requirement whose only evidence is
uninformative greens is the failure this umbrella keeps re-encountering: a check
that passes because nothing was measured, rather than because something was
proved.

WHAT STAYS OWED, narrowed to what it always should have been: the same first
call over the archive umbrella item 7 REBUILDS. Item 7's validation matrix runs
on both distributions and lists "the wrapper answering on its first call" by
name, and a rebuilt archive is a different artifact from the published one, so
that re-run is item 7's by right rather than by deferral. It does not hold this
requirement's verdict open.

## Out of scope for this issue

- the relocation pass and `DT_RPATH`, item 2, completed. This issue changes no
  ELF and reads no tag;
- the runtime closure, item 4. Whether the shipped tree CONTAINS the right
  libraries is a different question from which processes are pointed at them;
- the architecture key, item 5, the sqlite build, item 6, and the archive
  rebuild, item 7;
- `setenv`'s own content, including the hardcoded `CPLUS_INCLUDE_PATH` recorded
  below.

## Requirement clarifications for the wrapper

Two incidental defects were found while reading the wrapper. Neither is in
scope, and both are recorded so they are not lost:

- `src/install/env/python/bin/python` line 14 prints `DIR='...'` to stderr
  UNCONDITIONALLY, outside the `echo_dbg` guard that every other diagnostic in
  the file uses. Every invocation of the toolchain python writes a line of
  debug output to stderr;
- `src/install/env/python/bin/setenv` line 18 exports
  `CPLUS_INCLUDE_PATH` to a path under a developer's home directory that will
  exist on no deployment target.
