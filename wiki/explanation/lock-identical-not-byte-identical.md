# Lock-identical, not byte-identical

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

_Why a consumer application's Python environment stopped travelling
inside its archive, what a deployment proves instead of copying, and where
cplx's responsibility ends._

## A copied venv is a relocation problem

A consumer application used to ship its venv inside its own archive, the
tested bytes themselves (one measured at 529 MB). On the target, that tree
was relocated like any other, and the deployment spent several readiness
checks proving the copy had been re-anchored: the venv interpreter present
and executable, its ELF interpreter inside the prefix, `import ssl, zlib`,
the standard library anchored, every path in `pyvenv.cfg` naming the
prefix. Those checks exist only because a copy has to be moved.

The copy was also fragile in ways no check covered. A mirror with delete
semantics removes a venv the new archive does not carry, and the
installer's ELF pass, walking a shipped venv, replaced the `$ORIGIN` entry
through which a heavy wheel finds its bundled libraries. The pass now
skips every venv tree, but the deeper answer is not to ship one.

## What "lock-identical" promises

A venv created on the target is anchored by construction, so a whole class
of relocation invariants disappears instead of moving. What stays fixed is
identity, not bytes:

- the same canonical `uv.lock` and project metadata;
- the same original wheel files, each bound by SHA-256 to its lock hash;
- the same selection: groups, extras and the markers of the target;
- the shipped interpreter of the accepted toolchain, at the exact path
  `<application-root>/venvs/python_<full-version>_<project>`.

The pipeline tests one materialisation and the target runs another, built
from the same inputs. Byte equality of every installed file is not
claimed; that is the honest cost of the decision.

## Drift is detected, not assumed

Because the bytes are re-made, the deployment owes a check the copied venv
never needed. After the sync, it compares the installed distributions with
the lock's selection (missing, changed and extra ones all refuse), and it
requires every installed ELF, under `site-packages` and in the venv's
`bin/`, to equal one member of a retained original wheel, byte for byte.
That is the same inventory helper the toolchain's C++ generation
measurement uses. The interpreter is checked too: base executable, prefix,
full version, standard library inside the shipped Python, `pyvenv.cfg` and
script shebangs pointing nowhere foreign.

Readiness is the result of one operation, tied to the release, the
interpreter, the toolchain digest, the lock and the inventory. A previous
"ready" is invalidated before anything changes, so a half-finished sync can
never be read as a success.

## Offline by construction

Creating the venv on the target added two needs the deployment did not
have: `uv`, and somewhere to fetch wheels from. Both are answered by
shipping them as release inputs, in a digest-bound companion: the original
wheels, a qualified `uv` (an unmodified static artifact), the canonical
metadata, and the cplx helpers taken from one pinned commit.

The sync then runs with remote access denied: locked, offline, with no
Python download, no source build, an empty cache owned by the operation,
and a `file:` index derived from the immutable metadata. Only artifact
locations may differ between the canonical lock and the effective one;
versions, markers and hashes are compared before and after the sync.

Rollback changes nature as well. It no longer restores copied bytes: it
re-resolves the predecessor from *its* retained inputs, its lock, wheels,
`uv` and helpers. That is why the current and the preceding releases are
retained complete, outside the mirrored application tree, and why the
retention index only advances after a ready result. Missing inputs fail
before any mutation; recovery never downloads. Returning to an older
release that still shipped its venv uses that release's own procedure.

There is no atomic swap. A failed in-place sync leaves the root not ready,
and recovery (redeploy or rollback) may interrupt service. That trade is
accepted explicitly.

## Where cplx stops

| cplx | the consumer |
| --- | --- |
| verifies the local files it is handed, against recorded versions and SHA-256 | acquires them: downloads, mirrors, credentials, transport to the target |
| checks that the application root is serialized, through an attestation naming a lock the caller holds | provides that serialization across mirroring, sync and rollback |
| creates and syncs the venv offline, checks readiness, writes the evidence | decides when an attempt may run and who authorized it (its orchestration's own approval, for instance), and orchestrates it |
| packages without venvs, retains and selects releases, promotes on readiness | supplies its versioned runtime setup and its publication backend |

Nothing about where a consumer stores artifacts, how it authenticates or
who may deploy enters cplx. The reusable part stays offline and
verifiable; the consumer's delivery through its own orchestration is
qualified on its side.

## 👉 See also

- [Why binaries remember the build home](why-binaries-remember-the-build-home.md#where-dt_rpath-stops-wheels-with-their-own-runpath):
  why wheels need the consumer's runtime setup.
- [Deploy a Python environment offline](../how-to/deploy-a-python-environment-offline.md):
  the procedure.
- [Deployment venv helpers](../reference/deploy-venv-helpers.md): the
  scripts, their inputs and their failure modes.
