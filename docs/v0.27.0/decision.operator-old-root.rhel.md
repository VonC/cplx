# Operator decision: the superseded `tools/old` root on the build account

Host: RHEL 9.8 (Plow), the build account `deploy-account`.
Decided: 2026-09-11, by the repository owner, before the step 7 acceptance ran.
Action taken: DELETION, not the move the plan names as its default.

Names: infrastructure identifiers are substituted for the neutral vocabulary this
repository already uses in its retained evidence, so the account reads
`deploy-account` and the machine is named by its role rather than its hostname.
Observations, counts and digests are the run's own and are not altered.

## Why this document exists at all

Step 7 of
[plan.v0.27.0.toolchain-runtime-closure.md](plan.v0.27.0.toolchain-runtime-closure.md)
makes clearing this root an OPERATOR PREREQUISITE rather than a step of the
implementation, and fixes the order:

> an operator lists the exact directory on the build account, confirms it is the
> superseded interpreter root and not a live one, MOVES it out of `$HOME/tools`
> to a retained location on the same account, and re-runs the observed scope to
> confirm the root is gone. No script in this effort removes it, no step deletes
> a directory on a live account on its own authority, and the acceptance records
> the operator action and its retained location. **If the operator instead
> decides on deletion, that decision is recorded explicitly before the acceptance
> runs.**

The operator decided on deletion. This file is that explicit record, written and
committed before the re-run, so the acceptance capture beside it describes a
tree whose change is documented rather than discovered.

## What the checker objected to

The v0.27.0 closure checker refused the build account's tree with, among other
findings, two undeclared directories in the OBSERVED LOADER SCOPE:

```text
UNEXPECTED|observed|/home/deploy-account/tools/old/py3.13/lib|root|old
UNEXPECTED|observed|/home/deploy-account/tools/old/py3.13/lib64|root|old
```

`closure-config.txt` declares two roots, `python` and `git`. `old` is neither, so
a loader searching it would resolve names from a tree nobody reviewed. That is
the one refusal no waiver can carry.

## The confirmation that it was not live

Taken before the deletion, and recorded here because "confirm it is the
superseded interpreter root and not a live one" is the operator's obligation
rather than a formality:

| Check | Result |
| --- | --- |
| `tools/old` named in `.bashrc`, `.bash_profile`, `.profile`, `.env`, `.env_` | no match |
| symlinks under `~/tools` or `~/cplx` resolving into it | none |
| processes with a `cwd` or `exe` inside it, from `/proc` | none |
| the live interpreter | `~/tools/python/current` resolves to `tools/python/python-3.13.9`, a different tree |
| `tools/old/py3.13` last modified | 2025-08-23, thirteen months before this decision |
| shape | a Python VENV: `pyvenv.cfg`, `bin/activate`, `lib/python3.13` |

## What was removed, by manifest rather than by description

Recorded so the deletion is auditable after the bytes are gone.

| Property | Value |
| --- | --- |
| path | `/home/deploy-account/tools/old` |
| size | 199M |
| entries | 3658 files, 532 directories |
| full manifest | 4195 lines, SHA-256 `9e6a456ca3515b4e1e0fe1d924657717d8e0764196a84d11a0fb597a14146c25` |

The manifest is `find tools/old -printf '%y %10s %p\n' | LC_ALL=C sort`, taken
from `$HOME` on the account, and retained on the host at `/tmp/old.manifest.txt`
for the life of that filesystem. It is not committed here: 4195 lines of a
deleted venv is not review material, and its digest is what makes the summary
above checkable.

Three loose download artifacts sat beside the venv and went with it. They are
public, re-downloadable by version, and identified here by digest so the
deletion costs nothing that cannot be fetched again:

| File | SHA-256 |
| --- | --- |
| `numpy-2.3.2-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl` | `938065908d1d869c7d75d8ec45f735a034771c6ea07088867f713d1cd3bbbe4f` |
| `pymupdf-1.26.3-cp39-abi3-manylinux_2_28_x86_64.whl` | `454f38c8cf07eb333eb4646dca10517b6e90f57ce2daa2265a78064109d85555` |
| `patchelf-0.19.1-x86_64.tar.gz` | `a6818fef80128fb354423234ecacdcca3e993913d774e5d8346bc63f70fed4cf` |

The patchelf TARBALL went; the INSTALLED patchelf did not. `tools/patchelf/root/bin/patchelf`
is a separate root and is untouched by this decision.

## What this does and does not close

It closes ONE of the three refusal classes and part of a second. It does not make
the acceptance pass, and saying so here is the point: a decision record that
implied otherwise would be read later as evidence the gate had gone green.

| Refusal class | Before | After |
| --- | --- | --- |
| undeclared directories in the observed loader scope | 2 | 0 |
| `DT_NEEDED` names resolving nowhere | 30 | 21 |
| declared families over their permitted generation count | 2 | 2 |
| `UNDETERMINED` coherence results | 14 | 12 |

The 21 remaining names and both family pairs live under `tools/git/root` and
`tools/python/root`: compiler and binutils internals (`cc1`, `lto1`, `lto-dump`,
`as`, `objdump`, `readelf`, `gresource`, `libdebuginfod`) demanding
`libmpfr.so.6`, `libelf.so.1`, `libjson-c.so.5`, `libdebuginfod.so.1` and
`libopcodes-2.35.2-63.el9.so`, none of which the archive ships, plus
`libbfd`/`libopcodes` carrying generations `63.el9` and `66.el9` where the
declaration permits one each. No operator action reaches those. They are the
payload, and closing them is the rebuild umbrella item 7 owns.
