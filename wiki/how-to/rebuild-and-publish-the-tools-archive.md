# How to rebuild and publish the tools archive

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

Goal: produce a new `tools` archive on the build account, qualify those
exact bytes on both distributions, publish them to an immutable release
coordinate, and switch a consumer to the release, with a way back.

This is not the cplx source release ([Make a release](make-a-release.md)).
Publication here is irreversible: a release coordinate is never
overwritten, so every gate below runs before it.

## Prerequisites

- The consumer owns a publication adapter implementing the four operations
  `closure_publish.sh` calls (`upload_begin`, `upload_write`,
  `upload_abort`, `upload_commit`): a private stage, an atomic commit, and
  a SHA-256 read-back when the commit response is lost. **Prove it against
  the real backend first**, on a disposable probe coordinate, never on the
  coordinate you intend to release.
- A consumer pipeline that can run a candidate archive through its main
  chain with its own publication switched off.
- An independent Python 3.9 or later (not the candidate's) for the
  validators.

## 📋 Steps

1. **Select the Python version.** Set `CPLX_VERSION` explicitly; never let
   the repository tag lookup choose. Check upstream for regression reports
   on the newest patch release and date the check: take it unless a
   relevant blocking regression justifies the previous one, and select
   nothing while the finding is inconclusive. A version change rewrites the
   closure declaration's `subdir|python|python-<version>` record, so renew
   it ([Runtime closure checker](../reference/toolchain-runtime-closure.md#renewing-the-declaration-when-the-python-version-changes)).

2. **Refresh, rebuild, promote.** Refresh the sandbox payloads from the
   resolved package lists (`sp`; no host package is installed), rebuild
   Python with `irc`, and confirm its SQLite checks
   ([Check Python SQLite capability](check-python-sqlite-capability.md)).
   Git can be reused. Promote with `~/cplx/bin/rsync.sh`
   ([Promote a build into the live tree](promote-a-build-into-the-live-tree.md)).

3. **Package.** Run `~/cplx/bin/pkg_tools.sh`. It trims a private stage,
   runs the closure gate, and prints the archive path. Record the name, the
   size, the SHA-1 from `~/pkgs/tools.<stamp>.sha1` and the SHA-256 you
   compute: from now on the SHA-256 *is* the candidate. Any repackage, even
   to fix the installer it carries, is a new candidate.

4. **Qualify on both distributions.** Compose the controls at a commit with
   `ci/deliver-closure-tools.sh --bundle`, pin the archive and the bundle
   by SHA-256 in the consumer, and run the candidate with publication off
   ([Validate a change on a foreign CI agent](validate-a-change-on-a-foreign-ci-agent.md)).
   - Debian agent: relocation without any shim, the wrapper's first call,
     `import ssl, zlib, sqlite3`, the toolchain git, version-node
     coherence, the locked sync then the heavy-wheel imports with no wheel
     patching, the whole-scope ABI listing and a conclusive live trace, and
     the full test run with coverage;
   - RHEL: deployment and redeployment over an existing prefix with
     readiness checks, and the operator flow (session and `.env` sourcing).

5. **Settle the C++ generation (D10).** On the agent, after the sync,
   `tools_wheel_inventory.sh capture` records the exact wheels and their
   installed ELFs; on the build host, `materialize` them and run
   `closure_d10.sh` with both candidate generations and `--wheel-root`. If
   the answer differs from the shipped generation, rebuild once, repackage,
   and measure again: the second reading must return the same generation.

6. **Validate the record, then publish.** Keep every result in the release
   record (archive-indexed JSON, captures referenced by digest) and run,
   with `$PY39` the independent interpreter:

   ```bash
   SHA=$("$PY39" tools_release_record.py publication --record <record.json> \
       --archive <tools.stamp.tar.gz> --evidence-root <evidence> \
       --release-revision <cplx-sha> --capture <local-capture.json>)
   CPLX_TOOLS_RELEASE=1 bash closure_publish.sh --archive <tools.stamp.tar.gz> \
       --commit <cplx-sha> --repo <cplx-checkout> --results <verification-results> \
       --adapter <consumer-adapter> --expected-sha256 "$SHA"
   ```

   The validator pins the qualified interpreters. It accepts a record whose
   `candidate.python` is exactly `3.13.15` with a `regression.decision` of
   `clean`, or exactly `3.13.14` with `blocking regression`. Any other
   version refuses (`unsupported release Python`), and so does any other
   pairing, an inconclusive finding included (`Python selection requires a
   conclusive regression decision`). It also requires a non-`SNAPSHOT`
   releases coordinate. Pass the explicit archive: never let a `latest`
   link reselect the bytes.

7. **Adopt with publication off.** Remove the candidate inputs, raise the
   consumer's tools pin to the new release, and keep its application
   uploads off. One run through the normal pin must prove the downloaded
   digest, the pin read at startup, the selected interpreter and the whole
   integration chain. Run the validator's `completion` phase; only then
   switch uploads back on.

## ✅ Check

`closure_publish.sh` ends with `CLOSURE PUBLICATION OK: archive identity
<sha256> under configuration <digest>`, the published asset reads back to
the accepted SHA-256, and `tools_release_record.py completion` exits 0.

## ↩️ Recover on failure

- **Before publication**: nothing is public. Fix, repackage, and qualify
  the new candidate; old evidence never transfers to new bytes.
- **Commit not confirmed** ("publication was not confirmed"): the release
  may exist. Reconcile by reading the asset back and comparing its SHA-256;
  never retry the upload, never adopt, until that answer is known.
- **Adoption fails**: restore the previous tools pin *together with* its
  compatible consumer configuration, uploads still off, and verify that
  combination through the normal gate before uploads resume. The failed
  release stays as it is; a fix is a new candidate and a new version.

## When a new Python version is qualified

The accepted pair is code, not configuration: a record naming a newly
qualified version refuses until the validator is changed. Qualifying a new
patch release (the newest becomes the preferred version, the one before it
the fallback) is a reviewed change in three places:

- `validate_metadata` in `src/setups/env/bin/tools_release_record.py`: the
  set `candidate["python"]` must belong to, and the rule that requires
  `clean` for the preferred version and `blocking regression` for the
  fallback;
- `tests/unit/tools_release_record/test_tools_release_record/test_tools_release_record_tdd.py`:
  the `python` of the baseline record, the fallback case
  (`test_renewal_fallback_and_one_d10_rebuild_are_supported`), and the
  refused version in `test_required_metadata_mutations_fail_closed`, which
  must stay outside the new set;
- the closure declaration's `python-<version>` record, renewed as step 1
  describes.

## 👉 See also

- [One archive, two distributions](../explanation/one-archive-two-distributions.md):
  why both hosts are required.
- [Runtime closure checker](../reference/toolchain-runtime-closure.md):
  the gate, the release-record binding and the D10 inputs.
- [Packaging and relocation tools](../reference/relocation-tools.md):
  `pkg_tools.sh` and `install_pkg.sh`.
