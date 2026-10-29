# A release that installs itself

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

_Why, when a consumer's delivery orchestration runs a deployment step between
its stop and its start, the release is best shipped as one flat bundle whose
own entry installs it with the cplx helpers, and why that removes the need for
a signed selection._

## Two shapes of orchestration

Many operations teams run deliveries through a fixed sequence: stop the
service, fetch an archive, start the service. When that is all the
orchestration offers, the code that installs a release has to run inside the
stop or the start, that is inside the release being replaced. It must then
decide alone whether the run is a delivery, which release to install and
whether that choice is still current: a signed selection is one way to tell
it.

When the orchestration adds a deployment step between stop and start, the
incoming release can carry its own installer. Nothing has to be prepared
inside the outgoing release, and a change to the installer ships with the
release that needs it, instead of one release earlier.

## The bundle

The cplx inputs already form a closed set: the release record
(`release-inputs.txt`), the application archive, the entry script, the
companion and the `tools` archive, all bound by SHA-256 to the record. A
bundle is those files side by side, at the top level of one archive. The
deployment step runs the entry; the entry checks every member against the
record before anything changes.

Keeping the members at the top level matters when the orchestration stages a
download one item at a time while the service is stopped: an application
archive staged as is can cost one remote task per directory, a bundle of a few
files costs a few.

## What the entry does with the helpers

1. Verifies the members against the record, and refuses before any change
   when one differs.
2. Installs under the consumer's lock and service hold: the application and
   `tools` archives, then the venv created offline from the companion
   (`deploy_venv.sh`), at its exact path.
3. Checks the installed tree's readiness and promotes it only then
   (`promote --ready`): the retention index names it current and keeps the
   previous release as predecessor.
4. Starts the release and waits for the consumer's own proof of health.
5. On a failure after a change, reinstalls the last ready release from its
   own retained inputs (`select`), without downloading anything, and starts it
   again.

## Why no signature

A signature checked by the delivered entry cannot prove where the entry came
from: the checker arrives inside the payload it checks. Provenance belongs to
the orchestration that chose and fetched the bundle, under its own
authorization. What the entry checks is integrity against accidents: every
member against the record, the record against the identity it was built
with.

## Where cplx stops

The orchestration, its approvals, the service hold and the proof of health
belong to the consumer. cplx supplies the verified, offline and retained part:
the record, the venv creation and sync, readiness evidence, retention and
selection. The same helpers serve both orchestration shapes; only the place
that runs the entry changes.

## 👉 See also

- [Lock-identical, not byte-identical](lock-identical-not-byte-identical.md):
  why the venv is created on the target, and where cplx stops.
- [Deploy a Python environment offline](../how-to/deploy-a-python-environment-offline.md):
  the procedure.
- [Deployment venv helpers](../reference/deploy-venv-helpers.md): the
  record, the companion and the retention layout.
