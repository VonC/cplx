# How to validate a change on a foreign CI agent

<img src="../assets/logo-cplx-ship-transparent.png" alt="" height="90" align="right">

Goal: prove a cplx change on the Debian CI agent that runs a consumer's
pipeline, with verification bytes that come from cplx at a known commit,
although the agent has no access to cplx at all.

Background: the agent is reached only by committing to the consumer's
pipeline repository. It runs throwaway containers whose `uname` reports
the *host* kernel, so the distribution is read from `/etc/os-release`.
Why the agent and not the build host:
[One archive, two distributions](../explanation/one-archive-two-distributions.md).

## Prerequisites

- The change committed in cplx, with its full 40-character SHA.
- A probe stage in the consumer's pipeline that cplx maintainers may edit
  without touching the reviewed stages, and an artifact location the agent
  can download from.
- The bytes final before the push: lint and the RHEL run first, since any
  later edit means a new digest, a new pin and another build.

## 📋 Steps

1. **Choose how the verification bytes travel.** Nothing is fetched from
   cplx by the agent:
   - **a harness alone** travels as a *verification-only* copy in the
     consumer repository (never delivered, never packaged) with an identity
     manifest generated from a freeze commit: `freeze_commit`,
     `harness_path`, and `file_sha256`, the SHA-256 of the file bytes at that
     commit (not a Git blob id). The probe compares its copy with that
     manifest; the authority is the same comparison made on the cplx side;
   - **the authoritative tools** are composed where a cplx checkout exists:

     ```bash
     bash ci/deliver-closure-tools.sh --repo <cplx-checkout> --commit <40-hex> \
         --bundle verification.<short>.tar.gz
     ```

     The last line, `BUNDLE|COMPLETE|<commit>|<sha256>|<file>`, gives the
     digest. `--into <dir>` places the eight copies directly instead, for a
     workspace that has the checkout.

2. **Pin, publication off.** Upload the bundle (and a candidate archive,
   if the change is in the archive) where the agent can fetch it, then
   commit their SHA-256 values and the cplx commit to the consumer's pin
   file, with the consumer's own publication switched off. The consumer's
   adapter must check the bundle's `acceptance/verification.sha256` and
   `acceptance/source-revision.txt` before extracting anything, and refuse
   a missing or mismatched input rather than fall back to a copy found
   inside the candidate.

3. **Run the probes in parallel.** Each probe writes only into its own
   process-keyed scratch directory and its own evidence file, which is what
   makes the parallel run safe. A probe that *records* an oracle for a
   later check runs first and alone, and the check itself runs in the
   following build: a set measured in the same run it is checked against
   would pass with a member missing.

4. **Add the control.** In the same build, run the reverted fix (or the
   pre-change copy) and expect it to fail the way the defect does. Without
   it, a pass cannot be told apart from an agent where the defect never
   fires.

5. **Retain the evidence.** Archive the evidence files from the build and
   copy them out before CI retention removes them. Confirm which revision
   the build checked out from the build itself, not from your local
   tracking branch.

## ✅ Check

- Every probe reports its own structured result, and the required ones say
  `pass`: a job ending in SUCCESS is not a result, and an inconclusive or
  empty observation never counts as one.
- The evidence names the cplx commit, the bundle and archive digests, the
  agent's `/etc/os-release`, and the image or container identity.
- The control failed as expected.

## ⚖️ The two-host rule

The RHEL build host and the Debian agent prove different things, and a
change that touches both distributions needs both:

| Host | Proves | Cannot prove |
| --- | --- | --- |
| RHEL build or deployment host | no regression where the product runs today; deployment, redeployment and the operator flow | that a fix for a foreign-distribution defect works: the defect cannot fire there |
| Debian agent | that the fix works where the defect fires, against its control | anything about the RHEL operator flow |

A mechanism can often be proved anywhere first (by planting a failing
helper, for example), but only the agent turns a plausible fix into a
working one.

## 👉 See also

- [Runtime closure checker](../reference/toolchain-runtime-closure.md#the-delivered-set-and-the-acceptance-bundle):
  the delivered set and the bundle format.
- [Why the archive declares its own scope](../explanation/why-the-archive-declares-its-own-scope.md#controls-travel-separately-from-the-candidate):
  why the controls never come from the candidate.
- [Rebuild and publish the tools archive](rebuild-and-publish-the-tools-archive.md):
  the platform acceptance this procedure serves.
