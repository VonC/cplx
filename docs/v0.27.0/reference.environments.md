# Reference: the two environments v0.27.0 is validated on

- Type: reference
- Scope: the v0.27.0 cycle, every requirement under
  [draft.v0.27.0.debian-agent-tools.md](draft.v0.27.0.debian-agent-tools.md)

Every v0.27.0 requirement makes a claim about where the archive runs, and every
one of those claims is settled on one of exactly two hosts. Until now their
identity was spread across capture headers, a capability file and one gitignored
operations note, so each plan restated the parts it needed and no document said
which host could answer what. This is that document.

Requirement, design and plan documents reference this file rather than repeating
a host description. When a version or a measurement here changes, it changes in
one place.

---

## RHEL 9.8 (Plow), the deployment target that is also the build host

### Identity

| Property | Value | Source |
| --- | --- | --- |
| distribution | Red Hat Enterprise Linux 9.8 (Plow) | [capability.rhel-9.8.txt](capability.rhel-9.8.txt) |
| glibc | 2.34 family | umbrella, "the deployment targets" |
| bash | `5.1.8(1)-release` | [capability.rhel-9.8.txt](capability.rhel-9.8.txt) |
| `declare -A` | supported, MEASURED on the exact target 2026-08-18 | [capability.rhel-9.8.txt](capability.rhel-9.8.txt) |
| coreutils | `cp (GNU coreutils) 8.32` | [measurements.copy-form.rhel.txt](measurements.copy-form.rhel.txt) |
| rsync | 3.2.5, PRESENT | [measurements.mtime-engines.rhel.txt](measurements.mtime-engines.rhel.txt) |
| patchelf | 0.19.1 | [verify.acceptance.scope.rhel.txt](verify.acceptance.scope.rhel.txt) |
| filesystem | xfs | [measurements.manifest-forms.rhel.txt](measurements.manifest-forms.rhel.txt) |

THE KERNEL ROLLS AND IS NOT PINNED HERE. Three values were observed across this
cycle: `5.14.0-687.24.1.el9_8` (2026-08-09 to 08-11), `5.14.0-687.36.1.el9_8`
(2026-08-18) and `5.14.0-687.41.1.el9_8` (2026-08-27). Any check keying on an
exact kernel string would fail on the next patch window, so nothing in v0.27.0
does; the captures record what they saw and are dated.

### Role

It is NOT only a deployment target. It carries `patchelf`, and it is where the
relocatable Python is built, which is the reason
`src/setups/pkgs/python/python_rhel_9.8_x86_64.txt` exists. Build and deployment
now share the same OS: the build sandbox compiles against CentOS 9 Stream mirror
RPMs (the list files are named `rhel_9.6`, the mirrors behind them roll forward).

It is therefore the only host that can answer an exact-target question: the
capability gate (`--target-capability` / `--target-is-exact`), the rsync half of
the copy-engine measurements, `deploy_pkgs.sh` end to end, and the operator flow.

### Access

Over ssh, to an UNPRIVILEGED account. Nobody gets root or sudo on a corporate
server here, so anything needing privilege is not a plan. The host handle, the
account and the deployment recipe live in the gitignored
`a.infra-access.local.md` at the repository root, and are deliberately not
restated in tracked documents.

### The monitoring preload, an asymmetry that matters

Visible in any `ldd` on these servers: `/lib64/liboneagentproc.so` is injected
into every process through the system preload. The CI container has no
equivalent, so the RHEL side is the LESS isolated of the two, and a host-built
library lands inside the relocated toolchain's processes there.

- it is `static-pie linked` and binds nothing from the prefix, so forcing
  `DT_RPATH` cannot affect it;
- it is an INJECTION SHIM: mapped everywhere, it loads the full agent only for a
  process it classifies as a monitored service. A `python3 -c` one-liner gets 1
  thread, 0 sockets and no log, identically for relocated and system python, so
  a differential compares nothing with nothing;
- `oneagentctl` EXISTS at `/opt/dynatrace/oneagent/agent/tools/oneagentctl` and
  is `Permission denied` for this account. An earlier session recorded it as
  absent from "the vendor's usual paths", which was a traversal failure read as
  an absence. Write "not executable by this account", never "does not exist",
  unless the path was actually listable. See
  [request.monitoring-observable.rhel.md](request.monitoring-observable.rhel.md).

### What this host CANNOT prove

Anything whose cause needs a foreign distribution. The shipped libc is the host
libc family here, so the Q20 wrapper defect is invisible by construction: a run
that passes on RHEL says the fix did not regress, never that it works.

---

## Debian 12 (bookworm), the Jenkins CI agent

### Identity

| Property | Value | Source |
| --- | --- | --- |
| distribution | Debian GNU/Linux 12 (bookworm), throwaway Docker containers on Jenkins | umbrella, "the CI agent" |
| glibc | 2.36 (`libc6 2.36-9+deb12u10`) | develop#19 ABI probe |
| libgcc-s1, libstdc++6 | `12.2.0-14+deb12u1` | develop#19 ABI probe |
| libsqlite3-0 | `3.40.1` | develop#19 ABI probe |
| zlib1g | `1.2.13` | develop#19 ABI probe |
| host ceilings | `GLIBC_2.36` (libc), `GLIBC_2.35` (libgcc_s) | develop#19 ABI probe |
| bash | `5.2.15(1)-release` | [verify.relocation.step0.debian.txt](verify.relocation.step0.debian.txt) |
| coreutils | `cp (GNU coreutils) 9.1` | [measurements.copy-form.debian.txt](measurements.copy-form.debian.txt) |
| readelf | `GNU readelf (GNU Binutils for Debian) 2.40` | [verify.relocation.step0.debian.txt](verify.relocation.step0.debian.txt) |
| patchelf | 0.19.1, taken from the extracted prefix (`./prefix/tools/bin/patchelf`) | [verify.relocation.step0.debian.txt](verify.relocation.step0.debian.txt) |
| rsync | ABSENT | [measurements.destination-shape.debian.txt](measurements.destination-shape.debian.txt) |

TWO PROPERTIES THAT SURPRISE A READER OF THESE CAPTURES:

- `uname` INSIDE THE CONTAINER REPORTS THE RHEL HOST KERNEL. Every Debian
  capture in this directory carries `Linux 5.14.0-687.*.el9_8.x86_64`, because
  the container shares its host's kernel and only the userland is Debian. A
  check reading `uname` to identify the distribution is wrong here, and the
  distribution must be read from `/etc/os-release` instead;
- rsync's absence is not an accident of one image, it is the defect umbrella
  item 1 exists to remove. Measurements taken here report the rsync cases
  "unavailable" rather than failing, so a capture showing only the fallback half
  is the instrument working.

### Role

Where the discovery pipeline relocates the archive to run tests, package and
publish. It is the ONLY Debian host in hand, so every claim that needs a foreign
distribution is proved here and nowhere else.

### Access

NOT interactive. The agent is reached only by committing to the pipeline
repository and running a build.

| What | Where |
| --- | --- |
| pipeline repository | the consuming project's, branch `develop`; its working tree is named in `a.infra-access.local.md` |
| the branch Jenkins actually builds | the `cicd` push URL of `origin`, NOT its fetch URL |
| cplx probe file | `ci/Jenkinsfile.diagnostics` |
| stage entry point | `verifyCplx()`, one `parallel` over every probe, `failFast: false` |
| harness copies | `tools/*.verification-only.*`, never delivered, never packaged |
| captures | `$WORKSPACE/a.evidence/*.debian.txt`, archived by the root Jenkinsfile's post block |

`ci/Jenkinsfile.diagnostics` is owned by the cplx maintainer by its own header:
probes may be added, moved or deleted there without touching the pipeline's
reviewed stages. Landing a probe is therefore an ordinary commit and push, not a
negotiation.

THE AGENT HOLDS NO CREDENTIALS FOR CPLX. This is the reason every cplx harness
travels as a verification-only copy plus an identity manifest rather than being
fetched: the agent cannot obtain an authoritative digest on its own, so the
authority is an independent comparison performed on the cplx side.

`origin` in the pipeline repository is a MULTI-PUSH remote whose fetch URL is
not the URL Jenkins clones. Read what a build ran from the cicd remote
(`git ls-remote --heads <cicd-url> develop`), never from `origin/develop`.

### Sequencing rules the agent imposes

- the step 2 oracle recorder runs FIRST AND ALONE, before the parallel. Its rows
  are committed upstream between two builds, so step 2 needs TWO builds by
  design: the first records the selected-set oracle, the second checks the
  archive against that committed record. A set measured in the same run it is
  checked against would pass with a member missing, which is the failure it
  exists to catch;
- probes write only into pid-keyed scratch directories and their own evidence
  files, which is what makes the parallel safe. Running them in sequence cost 31
  minutes and bought nothing;
- `abiContract()` and the loader probe REPORT, they never gate. Both print their
  inventory and call themselves inconclusive rather than implying a verdict,
  because three earlier findings of this effort were instrument errors.

---

## What each host is asked to prove

The umbrella validation matrix, before any publication:

| Check | Debian 12 container | RHEL 9.8 |
| --- | --- | --- |
| `install_pkg.sh` relocation, no shim | required | required (redeploy over an existing prefix) |
| Wrapper `python3 --version`, first call | required | required |
| `import ssl, zlib, sqlite3` | required | required |
| Toolchain `git --version` | required | required |
| Version-node coherence: every demand of a shipped library defined by the shipped libc | required | required |
| `uv sync` then `import pymupdf, pikepdf`, no wheel patching | required | required |
| ABI probe: shipped loader `--list` over toolchain ELFs and venv wheels | required | not applicable (host copies are compatible) |
| Live trace: `LD_DEBUG=libs,versions` on importing the heavy wheels | required | not applicable (host copies are compatible) |
| `pytest` with coverage and testmon active | required | optional (the Windows dev flow covers it) |
| `deploy_pkgs.sh` end to end with readiness checks | not applicable | required |
| Operator flow (`senv`, `.env` sourcing) | not applicable | required |

### How the v0.27.0 requirements allocate their steps

| Requirement | Any host | RHEL 9.8 | Debian 12 |
| --- | --- | --- | --- |
| 1, `rsync-cp-fallback` | - | steps 0 to 3 and acceptance, the `R-rs` and `R-fb` cells, by hand over ssh | steps 0 to 3 and acceptance, the `D-fb` cell, builds 38 to 55 |
| 2, `relocation-force-rpath` | - | step 6 acceptance, two ordered sessions on 2026-08-27, plus the exact-target capability | steps 0, 1, 2, 3, 4 and 6 through `relocation_step0_capture.sh`, build 130 |
| 3, `python-wrapper-foreign-distro` | steps 0, 1, 2: the mechanism, measured from the wrapper's own run through recording shims | step 3: no regression where the defect is invisible | step 5: THE ACCEPTANCE, the first call the defect actually breaks; step 4 lands the harness and obtains one capture |

Requirement 3 is the clearest illustration of why both hosts exist. Its defect
(Q20: the wrapper exports `LD_LIBRARY_PATH`, then calls host `readlink`, `mv`
and `ln`, which bind the shipped RHEL libc and die on `GLIBC_PRIVATE`) cannot
fire on RHEL at all. Steps 0 to 2 prove the mechanism anywhere by PLANTING a
failing helper rather than requiring one; step 3 proves nothing regressed; only
step 5 on Debian can tell a working fix from a plausible one, and it runs a
reverted-fix control in the same build so that a pass is distinguishable from a
pass on a host where the defect never fires.

---

## How a run is started on each

### RHEL 9.8

By hand over ssh, in the plan's stated order, with every artifact citing one run
identity (for example `rhel-acceptance-20260827T114631Z`). The deployment recipe
that works is measured at 334 seconds for 1.9G and is recorded in
`a.infra-access.local.md`. Three traps it names, all of which cost an evidence
pass:

- the prefix must be a dedicated volume, not tmpfs and not `/`, and `HOME` must
  be pinned to it, because the installer defaults to `$HOME`;
- the archive must be copied into `$PREFIX/pkgs/` as a REAL FILE, never a
  symlink: discovery is `find -type f` and a symlink is invisible to it;
- the python binary is `python3.13_bin`, not `python3*`. A `find -name
  'python3*'` picks up `python3.13-config`, a shell script that answers usage
  and exits 1, so the harnesses use `-name 'python3*_bin'`. Likewise
  `tools/git/bin/git` is a Bourne-Again wrapper rather than an ELF, so tag
  evidence comes from `tools/git/<version>/bin/git`.

### Debian 12

By commit and build:

1. land the harness copy and its manifest under `tools/` in the pipeline
   repository, and the probe in `ci/Jenkinsfile.diagnostics`;
2. push to the cicd remote and run a build;
3. download the retained `a.evidence/*.debian.txt` capture and commit it here.

A probe that needs a committed oracle needs two builds, as above.

---

## Evidence index

Which capture came from which host. Every file listed sits in this directory.

### RHEL 9.8

| File | What it records |
| --- | --- |
| [capability.rhel-9.8.txt](capability.rhel-9.8.txt) | exact-target `declare -A` capability, 2026-08-18 |
| [measurements.copy-form.rhel.txt](measurements.copy-form.rhel.txt) | copy-engine forms with rsync present |
| [measurements.destination-shape.rhel.txt](measurements.destination-shape.rhel.txt) | destination shapes under both engines |
| [measurements.manifest-forms.rhel.txt](measurements.manifest-forms.rhel.txt) | manifest field forms on xfs |
| [measurements.mtime-engines.rhel.txt](measurements.mtime-engines.rhel.txt) | whether a fractional source mtime survives each engine |
| [verify.step0.rhel.txt](verify.step0.rhel.txt) to [verify.step3.rhel.txt](verify.step3.rhel.txt) | requirement 1, candidate suites, `R-rs` |
| [verify.acceptance.rhel.txt](verify.acceptance.rhel.txt) | requirement 1 acceptance |
| [verify.acceptance.manifest-rsync.rhel.txt](verify.acceptance.manifest-rsync.rhel.txt), [manifest-cp](verify.acceptance.manifest-cp.rhel.txt), [manifest-control](verify.acceptance.manifest-control.rhel.txt) | the three equivalence manifests |
| [verify.acceptance.equivalence-diff.rhel.txt](verify.acceptance.equivalence-diff.rhel.txt), [equivalence-control-diff](verify.acceptance.equivalence-control-diff.rhel.txt) | the equivalence gate and the control that must differ |
| [verify.acceptance.rpath.rhel.txt](verify.acceptance.rpath.rhel.txt), [session2](verify.acceptance.rpath.rhel.session2.txt) | requirement 2 acceptance, two ordered sessions |
| [verify.acceptance.scope.rhel.txt](verify.acceptance.scope.rhel.txt) | requirement 2 step 6 scope run |
| [request.monitoring-observable.rhel.md](request.monitoring-observable.rhel.md) | what the unprivileged account can and cannot see of the monitoring agent |

### Debian 12

| File | What it records |
| --- | --- |
| [measurements.installer-contract.debian.txt](measurements.installer-contract.debian.txt) | the nineteen host commands and their behaviors on the agent |
| [measurements.copy-form.debian.txt](measurements.copy-form.debian.txt) | copy-engine forms, fallback half only |
| [measurements.destination-shape.debian.txt](measurements.destination-shape.debian.txt) | destination shapes, fallback half only |
| [measurements.mirror-root.debian.txt](measurements.mirror-root.debian.txt) | the mirror phase against the source tree |
| [verify.step0.debian.txt](verify.step0.debian.txt) to [verify.step3.debian.txt](verify.step3.debian.txt) | requirement 1, candidate suites, `D-fb`, builds 38 to 46 |
| [verify.acceptance.debian.txt](verify.acceptance.debian.txt) | requirement 1 acceptance, build 55 |
| [verify.relocation.step0.debian.txt](verify.relocation.step0.debian.txt) to [step6](verify.relocation.step6.debian.txt) | requirement 2, steps 0 to 4 and 6, build 130 |
| [verify.relocation.loader-probe.debian.txt](verify.relocation.loader-probe.debian.txt) | the loader exclusion measured on the second host, build 123 |

Requirement 3 adds `verify.wrapper-scope.sh`, its manifest and
`verify.wrapper.debian.txt` to this index when its steps run.

---

## What this document deliberately does not carry

- the RHEL host handle, the account name and any credential. Those live in the
  gitignored `a.infra-access.local.md`, and tracked documents name the host by
  its role ("the RHEL 9.8 deployment server", "the build account") as they
  always have;
- Jenkins job URLs and API tokens;
- anything measured on only one host and stated as a rule. Where a rule rests on
  a measurement, it is taken on BOTH hosts the archive runs on: the loader
  exclusion of requirement 2 is the worked example, measured on the deployment
  target and then re-measured on the agent, because a measurement taken on one
  host is a rule with one witness.
