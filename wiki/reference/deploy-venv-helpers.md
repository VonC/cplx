# Deployment venv helpers

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

The scripts in `src/setups/env/bin/` that let a consumer deploy its
application without shipping its venv: they verify locally supplied
release inputs, create and sync the venv offline at its exact path, check
readiness, and retain releases for recovery. They reach a target inside
the consumer's companion (`helpers/`, staged from one pinned cplx commit),
not inside the `tools` archive. The Python ones use `tomllib`, so they need
Python 3.11 or later; on a target the shipped interpreter runs them.

## The inputs and their binding

**The outer release record** (`release-inputs.txt`): UTF-8, one
`key=value` per LF-terminated line, exactly these ten keys, values limited
to `[A-Za-z0-9_./+-]`, no duplicate, never sourced or evaluated:

```text
schema=1                   application_version   application_sha256
entry_sha256               companion_sha256      tools_version
tools_coordinate           tools_sha256          helpers_revision
helpers_manifest_sha256
```

It binds the bytes of the four outer files: the application archive, the
entry script, the companion and the `tools` archive. Its own SHA-256 is the
release identity used by retention.

**The companion**: a tar holding `manifest.json` (schema 1) and exactly the
members it lists, each by path and SHA-256: `uv` (provenance
`original-static`), `metadata/pyproject.toml` and `metadata/uv.lock` (plus
any workspace member), the target and selection profiles, the original
wheels (each matched to a hash in the lock), the transport mapping, the
consumer's runtime setup, and `helpers/`: `deploy_venv.sh`, the
`deploy_venv_*.py` modules but publication, `tools_wheel_inventory.py`/`.sh`,
`install_pkg.sh`, and the consumer's `helpers/runtime_env.sh`. The inner
manifest never hashes the companion, so no digest is circular.

## Scripts

| Script | Operations | On refusal |
| --- | --- | --- |
| `deploy_venv.sh` | the lifecycle entry, [below](#deploy_venvsh) | exit 2 before the lifecycle, 5 not ready |
| `deploy_venv_inputs.py` | `verify`; `assemble` a new companion (`--record` also writes the outer record); `extract` into a new directory after checking every member; `stage-helpers` from `--source-repo` at a full `--revision` | 2, `Release inputs refused` |
| `deploy_venv_release.py` | `record`, `preflight`, `qualify`, `ci-check`, `select`, `promote` | 2, `Release refused` |
| `deploy_venv_transport.py` | `prepare` and `check` the effective offline metadata; `probe` | 2, `Offline transport refused` |
| `deploy_venv_probe.py` | library behind `probe`: native qualification in a network namespace holding only loopback, file index first, a loopback index serving declared bytes as fallback | through its caller |
| `deploy_venv_selection.py` | compares the lock's marker, group and extra closure, the retained wheels and the installed distributions; prints JSON | 5, `Selection INCONCLUSIVE` |
| `deploy_venv_archive.py` | `package`, `inspect`, `descriptor` ([below](#packaging-without-venvs)) | 2, `Archive refused` |
| `deploy_venv_publication.py` | `publication-check`; its `publish()` takes a consumer port with `digest(coordinate)` and `upload(coordinate, path)` | 2, `Publication refused` |
| `tools_wheel_inventory.py` | `capture`, `materialize`, `describe` ([closure reference](toolchain-runtime-closure.md#the-wheel-inventory-input)) | 5, `INCONCLUSIVE` |

## `deploy_venv.sh`

```text
deploy_venv.sh --tools-prefix <abs>/tools --helper <abs-file> --runtime-setup <abs-file>
    --evidence-root <abs> --application-root <abs> --project <suffix>
    --manifest <abs>/manifest.json --profile <abs> --selection-profile <abs>
    --serialization-attestation <abs>
```

The shell part requires native Linux, absolute paths, regular files (not
links) for `--helper` and `--runtime-setup`, and exactly one
`python3*_bin` under `<tools>/python/current/bin`. It sources the runtime
setup, then runs the lifecycle under that interpreter in isolated mode,
importing its sibling modules from the `--helper` file's directory:

1. invalidate `readiness.json`; check the attestation
   (`{"schema":1,"application_root":...,"lock_path":...}`): a non-blocking
   lock on that file that *succeeds* means nobody holds it, and refuses;
2. verify every companion member and the three outer files, that both
   profiles are bound by the manifest, the target OS and architecture,
   the installed application metadata, the toolchain digest and version,
   that the running interpreter is the selected one, and `uv --version`;
3. derive `<application-root>/venvs/python_<x.y.z>_<project>` (dashes in
   the suffix become underscores); refuse a link or a foreign tree;
4. create the venv when absent (`uv venv --python <python>
   --no-python-downloads`), else validate its base, prefix and version;
5. run `uv sync --locked --offline --no-build --no-install-project
   --no-install-workspace --python <python> --no-python-downloads` plus the
   selection's group and extra flags, against a `file:` index, with ambient
   `UV_*`, `PIP_*`, `PYTHON*`, `VIRTUAL_ENV` and proxy variables removed and
   `UV_OFFLINE=true`, `UV_PYTHON_DOWNLOADS=never`, `UV_NO_BUILD=true`,
   `UV_NO_SOURCES=true`, `UV_NO_CONFIG=true` and an operation-owned
   `UV_CACHE_DIR` set;
6. re-check the metadata round trip and the inputs, capture the installed
   ELF inventory against the wheels, verify the selection, re-check the
   serialization, and only then write `ready`.

Standard output carries `VENV=<path>` on success and, once the lifecycle
has started, always `EVIDENCE=<operation-dir>/result.json`; an earlier
refusal still leaves a not-ready record. `<evidence-root>/readiness.json`
is replaced atomically, `"state":"ready"` with the release, interpreter,
lock, profile and inventory digests, or `"state":"not-ready"`. Each
`operation-<id>/` keeps one log per command with its argv and exit status.

## Retention layout

```text
<retention>/index.json        {"schema":1,"current":<id>|null,"predecessor":<id>|null}
<retention>/<id>/release-inputs.txt    <id> is this file's SHA-256
<retention>/<id>/<prefix>.<application_version>.tar.gz
<retention>/<id>/tools.<tools_version>.tar.gz
<retention>/<id>/entry
<retention>/<id>/companion
```

The consumer populates it; `select --retention R --identity <id>`
re-verifies every file and prints the directory, and `promote ... --ready`
makes `<id>` current and the old current the predecessor. Without
`--ready`, `promote` refuses.

## Packaging without venvs

`deploy_venv_archive.py package --pkg-sh <pkg.sh> --target <folder>
--source-root <dir> --home-root <dir> [--add <item>]... [--tar-rule <rule>]...
[--required <member>]...` walks each declared root once, without following
links, and finds every `pyvenv.cfg` (a link to a venv counts). It passes
them to `pkg.sh` as literal `--no-wildcards --exclude=<path>` rules, then
inspects the produced archive: a `pyvenv.cfg` member, anything under an
excluded path, or a missing `--required` member refuses. `--tar-rule`
accepts only `--exclude=...` and the two wildcard-slash switches.
`descriptor` writes the same exclusions into a Maven assembly descriptor.

## 👉 See also

- [Lock-identical, not byte-identical](../explanation/lock-identical-not-byte-identical.md):
  why the venv is created on the target.
- [Deploy a Python environment offline](../how-to/deploy-a-python-environment-offline.md):
  the procedure.
- [Python wrapper](python-wrapper.md): the `python3*_bin` the lifecycle
  selects.
