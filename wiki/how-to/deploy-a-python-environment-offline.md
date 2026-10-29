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
  It takes the prefix as first argument and defines `app_runtime_run`
  ([contract](../reference/deploy-venv-helpers.md)).
- A lock the consumer holds on the application root for the whole
  operation, mirroring and recovery included.
- The consumer's service controls, deployment hold and health check. The
  cplx helpers reconstruct the environment and record readiness; the consumer
  owns stopping, starting and supervising its application.

## Run the consumer's delivery

For a stop/download/deploy/start delivery, publish one flat bundle containing
the entry, release record, candidate identity, companion, application archive
and tools archive. Select an approved release address before stopping. The
production release-only address is an operator prerequisite; the cplx helpers
do not enforce the consumer's release-selection policy.

Run the consumer's stop, download and deploy steps in that order. Its deploy
entry must verify the bundle, install under the application lock and service
hold, start under the hold, prove the expected revision through the local
health API, then release the hold under supervision of the same daemon. The
orchestration's final start completes the consumer's sequence.

Keep the previous release's own controls available for recovery. In the
validated consumer integration, a refusal restarts the installed release and
returns 2; a failed deployment that restores the last ready release returns 6;
failed recovery returns 7 and attempts to leave the service held and stopped.
Check the final diagnostic: it must report when restoring that hold or stopping
the service failed. An early refusal must execute nothing from the refused
bundle, and a failed component stop must remain a failure even if daemon stop
succeeds. These are consumer entry outcomes, separate from the helper codes in
[Deployment venv helpers](../reference/deploy-venv-helpers.md).

The following steps describe the cplx operations used inside that integration.

## 📋 Build and install with cplx helpers

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
   and run the delivered venv helper:

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

This proves environment readiness. Complete the consumer's start, expected
revision check and supervision checks before declaring the delivery successful.

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

- [Relocate an install to another prefix](relocate-an-install-to-another-prefix.md):
  installing the toolchain the venv is built from.
- [Deployment venv helpers](../reference/deploy-venv-helpers.md): inputs,
  operations and exit codes.
