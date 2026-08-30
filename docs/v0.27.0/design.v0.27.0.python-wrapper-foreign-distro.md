# Design v0.27.0 -- Keep the python wrapper working on a foreign distribution

Reference issue: [issue.v0.27.0.python-wrapper-foreign-distro.md](issue.v0.27.0.python-wrapper-foreign-distro.md)

---

## Context for v0.27.0 python-wrapper-foreign-distro

The requirement asks for one change of scope and one change of failure
behavior, in a single 91-line bash file. The scope change is decision D2: the
shipped search path must serve the interpreter and nothing else the wrapper
runs. The failure change is the requirement's own addition: an unusable helper
result must stop the wrapper rather than feed the surgery.

This design answers how those two fit in one place, and settles the one
question the requirement left open: what "unusable" means for each helper
result, given that the wrapper reads three different kinds of value from
`readlink` and treats a missing symlink as a legitimate state in one of them.

## Scope for v0.27.0 python-wrapper-foreign-distro

The v0.27.0 outcomes are:

1. Every host-tool invocation in the wrapper runs without `LD_LIBRARY_PATH`,
   and both interpreter invocations run with it.
2. `bin/setenv` is unmodified, so an operator sourcing it interactively is
   unaffected.
3. The first-run surgery stops rather than deriving paths from an unusable
   value.

Out of scope: `setenv`'s content, the relocation pass, the runtime closure, the
sqlite build, the archive rebuild, and the two incidental defects the
requirement records.

## Confirmed technical facts for v0.27.0 python-wrapper-foreign-distro

Read from the file rather than assumed.

- The export happens in `setenv` line 15 and reaches the wrapper by `source` at
  line 18. It is a plain `export`, so every child process inherits it.
- `readlink -f` at wrapper line 12 and inside `setenv` line 7 both run BEFORE
  the export exists. They are not affected and must not be changed.
- After line 18 the wrapper makes fourteen host-tool invocations and two
  interpreter invocations. The interpreter pair is lines 60 and 62, in the two
  arms of one `if`, and they are different binaries at different paths.
- The wrapper reads `readlink` output at three sites, and they do not mean the
  same thing:
  - line 30, `current/bin/python3`: on a fresh tree this is the real
    interpreter's name, and the value drives the whole surgery;
  - line 47, `current/bin/python3_target`: read only when line 32 found the
    tree already converted, so an empty answer here means a broken tree;
  - line 66, the venv's `python3`: read only when `-m venv` was requested.
- `bash` restores nothing automatically. An `unset` at function scope in a
  non-function context is permanent for the rest of the process, which is why
  the value has to be held in a variable rather than re-derived.

## Current behavior for v0.27.0 python-wrapper-foreign-distro

The export is in force from line 18 to the end of the file. On RHEL the host
tools and the shipped libraries are ABI-compatible and nothing shows. On Debian
the helpers die on `undefined symbol: _dl_readonly_area, version
GLIBC_PRIVATE`, `readlink` returns empty, and the surgery proceeds on paths
built from that empty value.

## Target behavior for v0.27.0 python-wrapper-foreign-distro

```text
line 18   source setenv                      export now exists
line 19   CPLX_SAVED_LD=$LD_LIBRARY_PATH     hold it
line 20   unset LD_LIBRARY_PATH              helpers run host-native
...
lines 30 to 57, 66 to 89                     fourteen helpers, no export
...
lines 60, 62                                 interpreter, export restored
```

The restore is per-invocation and not a global re-export, so no helper after
the interpreter call inherits it. The venv post-processing at lines 65 to 89
runs after line 60, and it is a helper block, so it must stay unset.

## Save, unset and restore for v0.27.0 python-wrapper-foreign-distro

ONE SAVE SITE, immediately after the source. Two restore sites, one per
interpreter arm, and nothing else.

The restore uses a per-command environment prefix rather than a re-export:

```bash
LD_LIBRARY_PATH="${CPLX_SAVED_LD}" "${DIR}/current/bin/${python3_target}" "$@"
```

Chosen over `export` before the call and `unset` after it, because the wrapper
does not always reach the line after: the interpreter call is the last thing a
normal run does, and an `export`/`unset` pair around it leaves the exported
state live for anything the interpreter itself spawns through the wrapper. The
prefix form is scoped to exactly one process.

Chosen over `env -u LD_LIBRARY_PATH` on each of the fourteen helpers, which is
decision D2's rejected option (b): fourteen call sites to keep correct against
one, and a later edit that adds a fifteenth helper inherits the export silently.
The save/unset form makes the unset state the default for the file.

An empty saved value is preserved as empty rather than unset, so a caller who
ran with no `LD_LIBRARY_PATH` sees the interpreter run the same way it does
today.

## Failing closed on an unusable helper result

The requirement asks the wrapper to stop rather than derive paths from an
unusable value. "Unusable" is not the same at the three read sites, and this
design states each rather than applying one rule everywhere.

| Site | Empty answer means | Design |
| --- | --- | --- |
| line 30, `current/bin/python3` | either a shape the wrapper does not support, or a dead helper | STOP. On an unconverted tree `python3` is a symlink onto `python3.13`, and the wrapper uses that answer as a FILENAME to `mv`. An empty answer is therefore never a usable state: it is a tree shaped differently than the surgery assumes, or a helper that died |
| line 47, `current/bin/python3_target` | a converted tree missing its back-pointer | STOP. Line 32 already established the tree is converted, so this must resolve |
| line 66, the venv `python3` | either no venv was created, or a dead helper | STOP. Reached only when `-m venv` was requested and the interpreter returned, so the venv exists |

All three stop. That is the honest reading: at every site the wrapper reaches,
the value it reads is one the tree is supposed to carry, so an empty answer is
a failure rather than a state.

The stop is a `fatal`-shaped exit: a message naming the helper, the path it was
asked about, and the fact that no change was made, then a non-zero exit before
any `mv` or `ln` runs. The surgery's first write is line 34, so the check at
line 30 protects the whole block.

## Why a distribution is not detected

No part of this design branches on the host distribution. The rule is "helpers
run against the host's own libraries", which is correct on RHEL and on Debian
and on anything else, and it needs no detection to be right. A design that
detected Debian would carry a list to maintain and would still be wrong on the
next distribution not on it.

## Equivalence and validation model

The defect is invisible on RHEL by construction, so the design must be provable
without a foreign distribution for everything except the end-to-end call. Three
observations carry it:

1. THE SCOPE, measured from the wrapper's own run rather than read from source:
   a helper invocation observes no `LD_LIBRARY_PATH`, and the interpreter
   invocation observes the saved value. Both are recorded by instrumenting the
   wrapper's own environment at those points, not by reasoning about the file.
2. THE FAILURE BEHAVIOR, by planting a failing helper. A `readlink` shim that
   exits non-zero and prints nothing reproduces the Debian failure's OBSERVABLE
   without reproducing its cause, and the observable is what the wrapper reacts
   to. This runs on any host.
3. NO REGRESSION ON RHEL, which is the only place that half can be checked.

What none of these can show is the helpers actually surviving a foreign glibc,
which is the end-to-end call the umbrella places in item 7's validation matrix.

## Design decisions for v0.27.0 python-wrapper-foreign-distro

| # | Decision | Chosen | Rejected |
| --- | --- | --- | --- |
| W1 | Scope mechanism | save/unset once after the source, restore per interpreter call | `env -u` per helper (D2 option b), fourteen sites to keep correct; builtins where possible (option c), which does not cover `mv`, `cp` or `sed` |
| W2 | Restore form | per-command environment prefix | `export` then `unset` around the call, which leaves the state live for anything the interpreter spawns and for a run that never reaches the line after |
| W3 | Empty saved value | preserved as empty | treated as unset, which would change behavior for a caller who had none |
| W4 | Unusable helper result | stop at all three read sites | stop only at line 30, which leaves the venv path deriving from an empty value |
| W5 | Distribution detection | none | detect Debian and branch, which needs a list and is wrong on the next host |

## Acceptance cases for v0.27.0 python-wrapper-foreign-distro

| Case | Setup | Expected |
| --- | --- | --- |
| A1 | first call, fresh tree, RHEL | version answered; `python3` a symlink to the wrapper, `python3.13_bin` the real interpreter, `python3_target` pointing at it |
| A2 | second call, converted tree | version answered through the existing symlinks, no surgery |
| A3 | helper made to fail at line 30 | non-zero exit naming the helper and the path; tree unmodified; no `mv` and no `ln` performed |
| A4 | scope probe | a helper invocation observes no `LD_LIBRARY_PATH`; the interpreter invocation observes the saved value |
| A5 | `-m venv` on RHEL | venv created and post-processed; helpers ran unset |
| A6 | caller with no `LD_LIBRARY_PATH` | interpreter runs with an empty value, not with the variable unset |
| A7 | `setenv` unchanged | byte-identical to its pre-change content |
| A8 | first call on Debian 12, fix applied | the wrapper answers its version and the tree is in the expected shape. Run on the CI agent, which is the only Debian host in reach and is reachable again |
| A9 | first call on Debian 12, fix REVERTED | the tree is mangled: `current/bin/_bin` appears. The control without which A8 cannot be told from a run on a host where the defect never fired |
