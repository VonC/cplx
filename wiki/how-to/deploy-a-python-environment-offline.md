# How to deploy a Python environment offline

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

Goal: deploy a consumer application whose archive carries no venv, and
create its environment on the target from the release lock, with remote
services denied, then prove it ready, and know how to go back to the
previous release.

Background: [Lock-identical, not byte-identical](../explanation/lock-identical-not-byte-identical.md).
Every script named below is described in
[Deployment venv helpers](../reference/deploy-venv-helpers.md). `$PY` is a
Python 3.11 or later; on the target, use the shipped interpreter of the
installed toolchain.

## Prerequisites

- An accepted `tools` archive, its version and SHA-256 recorded.
- The consumer's versioned runtime setup, which puts the shipped library
  directories first for its Python commands
  ([why](../explanation/why-binaries-remember-the-build-home.md#where-dt_rpath-stops-wheels-with-their-own-runpath)).
- A lock the consumer holds on the application root for the whole
  operation, mirroring and recovery included.

## 📋 Steps

1. **Package without venvs** (release side). Route the consumer's
   packaging through the adapter, which excludes every `pyvenv.cfg` tree
   and inspects the result:

   ```bash
   $PY deploy_venv_archive.py package --pkg-sh ~/cplx/bin/pkg.sh \
       --target <folder> --source-root <dir> --home-root "$HOME" \
       --required <archive-member>
   ```

   Name each release input that must survive (the canonical `uv.lock` and
   `pyproject.toml`, for instance) with its own `--required`.

2. **Build the release inputs** (release side). Write the companion's
   `manifest.json` naming every member by path and SHA-256, stage the cplx
   helpers from one commit, assemble, then write the outer record, which is
   published only after the complete companion qualifies:

   ```bash
   $PY deploy_venv_inputs.py stage-helpers --manifest <dir>/manifest.json --root <dir> \
       --source-repo <cplx-checkout> --revision <40-hex> --runtime <runtime_env.sh>
   $PY deploy_venv_inputs.py assemble --manifest <dir>/manifest.json --root <dir> \
       --archive companion.tar
   $PY deploy_venv_release.py record --application <app.tar.gz> --entry <entry> \
       --companion companion.tar --tools <tools.tar.gz> --output release-inputs.txt
   ```

3. **Supply and verify the local inputs** (target). Copy the record and
   its four files to release-specific storage outside the mirrored
   application tree, then check them before touching anything:

   ```bash
   $PY deploy_venv_release.py qualify --record release-inputs.txt \
       --application <app.tar.gz> --entry <entry> --companion <companion> --tools <tools.tar.gz>
   ```

   `preflight` checks the four digests only; `qualify` also opens the
   companion and checks every binding. The record is plain `key=value`, so
   a host `sha256sum` comparison can stand in before any Python exists.
   Retain the set as `<retention>/<record-sha256>/`.

4. **Install, then lay out the release root.** Install the application
   archive and, when it changed, the toolchain (`install_pkg.sh tools
   --archive <absolute-path>`). Extract the companion into a new directory
   and place the application archive, the tools archive and the entry
   script at the paths its `manifest.json` names:

   ```bash
   $PY deploy_venv_inputs.py extract --archive <companion> \
       --sha256 <companion_sha256> --root <release-root>
   ```

5. **Reconstruct.** With the lock held, write the attestation
   `{"schema":1,"application_root":"<app-root>","lock_path":"<lock-file>"}`
   and run the delivered entry:

   ```bash
   bash <release-root>/helpers/deploy_venv.sh \
       --tools-prefix <prefix>/tools \
       --helper <release-root>/helpers/deploy_venv_inputs.py \
       --runtime-setup <release-root>/helpers/runtime_env.sh \
       --evidence-root <evidence> --application-root <app-root> --project <suffix> \
       --manifest <release-root>/manifest.json --profile <target-profile> \
       --selection-profile <selection-profile> --serialization-attestation <attestation>
   ```

## ✅ Check

- The run prints `VENV=<app-root>/venvs/python_<x.y.z>_<suffix>` and exits 0.
- `<evidence>/readiness.json` reads `"state":"ready"`; anything else, or a
  missing file, means not ready. The `EVIDENCE=` path names the operation's
  `result.json`, whose `commands` list each step's log and exit status; a
  failure records its first failing command there.
- Only now advance retention:
  `$PY deploy_venv_release.py promote --retention <retention> --identity <record-sha256> --ready`.

## ↩️ Restore the predecessor

No download is allowed: recovery uses what was retained.

1. Read `<retention>/index.json` and run `deploy_venv_release.py select
   --retention <retention> --identity <predecessor>`, which re-verifies
   every retained file and prints its directory.
2. Reinstall the predecessor's application archive and toolchain, extract
   *its* companion, and run *its* `deploy_venv.sh` with its own helpers,
   `uv`, lock, wheels and profiles (steps 4 and 5).
3. Check readiness as above. A predecessor that still shipped its venv is
   restored with its own historical procedure instead.

A failed in-place sync leaves the root not ready and may interrupt
service: redeploy the new release or restore the predecessor, then check
readiness again.

## 👉 See also

- [Deployment venv helpers](../reference/deploy-venv-helpers.md): inputs,
  operations and exit codes.
- [Relocate an install to another prefix](relocate-an-install-to-another-prefix.md):
  installing the toolchain the venv is built from.
