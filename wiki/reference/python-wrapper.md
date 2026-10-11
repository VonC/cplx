# Python wrapper

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

The toolchain's `python3` is not the interpreter. It is a Bash wrapper,
`src/install/env/python/bin/python`, deployed as `tools/python/bin/python`
beside its `setenv`, which renames the real ELF on its first call and then
starts it with the shipped library path. This page describes the wrapper
as shipped since v0.27.0.

## Files, under `tools/python/`

| Path | What it is |
| --- | --- |
| `bin/python` | the wrapper |
| `bin/setenv` | sourced by the wrapper, unchanged for interactive operators: prepends `current/bin` to `PATH` (outside a venv), sets `PERLLIB`, `MANPATH`, and exports `LD_LIBRARY_PATH` to `root/usr/lib64`, `root/usr/lib`, `root/lib64`, `root/lib`, then the `current/` library directories |
| `current/bin/python3`, `current/bin/python3.<minor>` | after the first call, symlinks to `../../bin/python` |
| `current/bin/python3.<minor>_bin` | the real interpreter ELF |
| `current/bin/python3_target` | symlink naming that `_bin` file |
| `bin/pip`, `bin/pip3` | symlinks to `current/bin/pip3`, created when absent |

## Dispatch, in order

1. Resolve its own directory (`readlink -f`, `dirname`). This runs before
   any library path is set, so it is unaffected by what follows.
2. Source `setenv`.
3. Save `LD_LIBRARY_PATH` into the shell variable
   `CPLX_TOOLCHAIN_LD_LIBRARY_PATH`, then `unset LD_LIBRARY_PATH`. An empty
   value stays empty rather than becoming unset.
4. Note a `-m venv <dir>` among the arguments.
5. Read `current/bin/python3` (site `relink-read`). If it does not already
   point at `../../bin/python`, perform the first-run surgery: `mv` the real
   binary to `<name>_bin`, link `python3` and `<name>` to the wrapper, link
   `python3_target` to `<name>_bin`. Otherwise read `python3_target` (site
   `target-read`).
6. Create the `pip` and `pip3` links when absent.
7. Start the interpreter with the saved path restored **for that one
   command**: `current/bin/<target>`, or, when `VIRTUAL_ENV` is set, the
   venv's own interpreter copy under `$VIRTUAL_ENV/bin/`.
8. After a `-m venv <dir>` call, read `<dir>/bin/python3` (site `venv-read`),
   re-point that name at the wrapper, copy the real interpreter beside it
   with one more `_bin` suffix, and rewrite the name in the venv's `pip`
   scripts.
9. With `VIRTUAL_ENV` set to an existing directory, rewrite any `_bin_bin`
   left in the venv's `bin/` scripts (regular files only).

## The library path belongs to the interpreter only

`setenv`'s export points at the shipped RHEL libraries. Every helper the
wrapper runs is a host program found through `PATH`; with that export
inherited, a helper on another distribution binds the shipped libc and
dies on `undefined symbol: ..., version GLIBC_PRIVATE`. Before v0.27.0 this
emptied `readlink`'s answer and the surgery built paths such as
`current/bin/_bin`.

So the export is saved once and removed from the wrapper's shell. The two
interpreter starts (step 7) restore it as a per-command assignment,
`LD_LIBRARY_PATH="$CPLX_TOOLCHAIN_LD_LIBRARY_PATH" <interpreter> "$@"`,
never as an `export`: the interpreter and every process it spawns inherit
it, host programs included, while the wrapper's own later helpers do not.
Nothing branches on the distribution: helpers run against the host's own
libraries, which is correct everywhere.

## Fail-closed reads

`readlink` is the one helper whose output becomes a path, so each read
stops the wrapper when it fails or answers nothing:

| Site | Reads | An empty answer means |
| --- | --- | --- |
| `relink-read` | `current/bin/python3` | an unsupported tree shape or a dead helper; checked before the first `mv` |
| `target-read` | `current/bin/python3_target` | a converted tree missing its back-pointer |
| `venv-read` | `<venv>/bin/python3` | a venv that should exist but cannot be read |

The message is `python: readlink failed at <site>: '<path>'` on stderr,
with a non-zero exit and no `mv` or `ln` performed after it.

## Host programs it runs

`readlink` and `dirname` (step 1, before `setenv`), then `readlink`, `mv`,
`ln`, `cp`, `sed` and `grep`, all with no `LD_LIBRARY_PATH`. Everything
else is a Bash builtin.

## Running the ELF directly

A caller that needs no wrapper behavior may start
`current/bin/python3.<minor>_bin` itself: after relocation its `DT_RPATH`
finds the shipped libraries, and a venv created from it links to the ELF
rather than to the wrapper. uv driven with `UV_PYTHON`, and
`deploy_venv.sh`, which requires exactly one `python3*_bin` under
`current/bin`, both do this
([Deployment venv helpers](deploy-venv-helpers.md)).

## Known quirks

- Every call prints `DIR='<dir>'` on stderr, outside the debug guard; a
  caller that captures stderr sees it. Standard output is untouched.
- A non-empty `P_DBG` echoes each helper command on stderr.
- `setenv` exports a `CPLUS_INCLUDE_PATH` under a builder's home, which
  exists on no deployment target.

## 👉 See also

- [One archive, two distributions](../explanation/one-archive-two-distributions.md):
  why the defect only showed on a foreign distribution.
- [Why binaries remember the build home](../explanation/why-binaries-remember-the-build-home.md):
  what the relocated ELF finds through its own `DT_RPATH`.
- [CPLX variables](cplx-variables.md): `CPLX_TOOLCHAIN_LD_LIBRARY_PATH`
  is the wrapper's, not a switch.
