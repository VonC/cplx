# Step 8 final runtime-closure acceptance

Writer assessment: implemented, ready for independent code review. This record belongs to
[umbrella item 4](draft.v0.27.0.debian-agent-tools.md),
[the owning issue](issue.v0.27.0.toolchain-runtime-closure.md) and
[implementation Step 8](plan.v0.27.0.toolchain-runtime-closure.md).

## Final candidate and retained evidence

The candidate is tools.2026-09-13_135711.tar.gz, 537551298 bytes, built on
2026-09-13. Both hosts inspect these exact bytes:

```text
SHA-256 b381193aee3cc486bad4db478af5c8f6ca068a1ed5b2eefb32a107c8d53f4e90
SHA-1   14b81dfdcf87faea7c8d7f831e840f34a046444d
```

- [Packaging capture](acceptance.closure.step8.packaging.txt): full gate report,
  archive creation and unchanged source loader digests.
- [Loader inventory](acceptance.closure.step8.loaders.txt): every PT_INTERP
  path in source, archive and installation; all five loader lookup aliases;
  the earlier archive's failed second loader and the corrected candidate.
- [RHEL capture](acceptance.closure.step8.rhel.txt): final canonical source
  identities, cases and archive acceptance on RHEL 9.8.
- [Debian capture](acceptance.closure.step8.debian.txt): CI source identities,
  complete installed static report and provider inventory, application-venv
  ancestry, owned-process trace and live negative controls on Debian 12.

Packaging returns 0 in 115 seconds. Its checker returns 3 solely for the one
active sqlite waiver permitted by Q15: 602 ELF subjects, 4486 coherence needs,
63 needed names, 20 multi-candidate names and no refused duplicate. Unexpected,
undetermined and unresolved-needed counts are zero. Release publication still
requires its ordinary unwaived gate.

## Loader preservation and installation

The canonical loader SHA-256 is
133206056560962a63058c5e7aff1c69036f82ff7dc238e70209bdc3f7878e95.
All five lookup paths resolve to those bytes and return 0 from --version
before packaging, in the archive and after installation. Packaging retains
every lookup name through relative aliases. It refuses differing bytes,
broken links and escapes before changing any loader. Source loader digests
remain unchanged, and install_pkg.sh is unchanged.

The source has 296 PT_INTERP programs. The trim removes 51; archive and
installation have 245. The unchanged installer relocates 162 interpreter paths;
83 retain their system interpreter. The full inventory names those helpers.
This does not claim that every shipped ELF is an application entry point.

The earlier archive reproduces the second loader's changed digest and exit
139. The final installation returns 0 in 345 seconds; all loader aliases
execute, and the candidate reports Python 3.13.9 and Git 2.52.0.

## Host acceptance and controls

Debian build 170 passes all eight harness steps and reports all-exit=0.
Each host has zero failed cases. The closing RHEL Step 7 run consumes the
corrected final Debian capture and exits 0. RHEL Step 6 retains its declared
Debian-only exit 5; Debian answers that obligation in its passing full run.

| Step | RHEL cases | RHEL exit | RHEL seconds | Debian cases | Debian exit | Debian seconds |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | 62 | 0 | 26 | 62 | 0 | 17 |
| 1 | 73 | 0 | 2 | 73 | 0 | 2 |
| 2 | 91 | 0 | 2 | 91 | 0 | 1 |
| 3 | 132 | 0 | 24 | 132 | 0 | 15 |
| 4 | 152 | 0 | 19 | 152 | 0 | 11 |
| 5 | 254 | 0 | 9 | 254 | 0 | 8 |
| 6 | 271 | 5 | 10 | 272 | 0 | 9 |
| 7 | 149 | 0 | 109 | 162 | 0 | 1229 |

The RHEL Step 7 row uses the [closing capture](acceptance.closure.step8.rhel-closing.txt).
The original [RHEL capture](acceptance.closure.step8.rhel.txt), including its
earlier Step 7 exit 5, is preserved byte-for-byte because Debian consumed and
recorded its SHA-256. The closing run uses the same candidate archive and
verifies all 19 canonical source identities before running the unchanged harness.
It records `debian-capture PASS`, `rhel-half PASS` and the real-archive
rule-1 positive control, with 149 cases, zero failures and exit 0 in 109 seconds.

The Debian retention correction adds `Captured: 2026-09-13T15:08:19Z` from
the capture's existing date field and normalizes the exported file to LF.
Every measured line is preserved; the Debian CI job was not rerun.

```text
Original RHEL SHA-256 d28cb767dc927213a55a614e21855ecbc4486e6fd20cd9b667701a7938bff0df
Corrected Debian SHA-256 8d702a4c6e54f8dfd7a8eda20fae86d5392c65d74d7e0a5c2b57cdeb6a682458
Closing RHEL SHA-256 5e8f2e8150c416e6b2a2a9a24b1cb8ba326a30fd0bb67ffe8f0bb6ee12336c20
```

Jenkins build 170 subsequently completed with SUCCESS. The closure verdict is
supported by its explicit acceptance capture. Its owned Debian process, PID 1386470, records
`HOSTS|1386470|1`, `EXCLUDED|1386470|dynatrace|1` and
`FALLBACKS|1386470|0`: the only external object is the visible OneAgent module.

The application venv is newly created beneath the verifier's installation,
using the relocated candidate ELF's venv API without pip, with symlink entry points. Its effective runtime
configuration must identify that venv and base paths under the same candidate.
Creation and observation use LC_ALL=C; this bounded process does not map host
locale data. The observer receives only the owned PID. The capture retains the
VENV, OWNED, PROCESS, OBJECT, HOSTS, EXCLUDED and FALLBACKS records, rather than only a verdict.

The first verification supplies missing-live evidence. Empty and host-object
controls call the authoritative live observer over the same installed prefix.
The empty trace must return 4 and INCONCLUSIVE; the planted host object must
return 1 and REFUSED. Step 6 retains reinstall, completion-marker and corruption
controls. The removed incomplete stand-in archive supplies no evidence.

Builds 166 and 167 failed six live assertions and returned closure aggregate 1.
Build 166 exposed the wrapper's venv rewrite failure; build 167 retained the
wrapper bootstrap, whose host ln loaded the bundled libc and failed on a
GLIBC_PRIVATE symbol. Neither run is acceptance evidence. The final path
selects a contained relocated ELF, bypasses the shipped shell wrapper, and
creates venv symlinks. The same helper runs as an early CI preflight before
the complete acceptance installation and report.

Build 168 reached that interpreter and venv but failed the early live probe:
the host injected liboneagentproc.so. Its trace reported six candidate objects
and one external monitoring object, with aggregate 1. It is also excluded.

The owner approved a general Dynatrace exclusion, on build, CI and deployment
hosts and in release verification. The authoritative observer recognizes the
vendor library family in its installation tree and standard system aliases,
without a version/digest pin or an injection-provenance prerequisite. It retains
each OBJECT as excluded-dynatrace, the raw HOSTS count and a separate EXCLUDED
count. The owned process must have zero FALLBACKS and a usable non-monitoring
inventory. Other external runtime libraries still refuse, including libraries
in the Dynatrace directory and lookalike paths. CI runs in its ordinary
environment; namespace isolation and preload changes are unnecessary.
The Step 6 controls exercise accepted version changes and aliases, deleted and
duplicate mappings, monitoring-only inconclusiveness and additional host
libc, loader, libpython, libm and libgcc refusals. This changes the live scope
generally; the Q15 sqlite acceptance and strict static release gate are separate.
Build 169 refused namespace creation with Operation not permitted and aggregate 1.
It is retained as failed evidence. The earlier native isolation probe passed
with zero external objects; that auxiliary result does not replace Debian
acceptance. The final acceptance uses the owner-approved monitoring scope and
reports both raw external objects and remaining runtime fallbacks.

An auxiliary RHEL probe in the ordinary monitored environment retained six
candidate objects and `/usr/lib64/liboneagentproc.so` for owned PID 3118437.
It reported `HOSTS|3118437|1`, `EXCLUDED|3118437|dynatrace|1` and
`FALLBACKS|3118437|0`, with a conclusive verdict. It validates the exclusion on
an injected native process; the required foreign-host proof remains the final
Debian acceptance capture above.

## Bounded CI transport and cleanup

Requirement Q13 records the human's Option B decision. The transport selects
one snapshot version, exact asset basename and SHA-256. CI checks the digest
before extraction and requires publication mode off. The ordinary release pin
remains 9.13.4. Controls reject a wrong or missing digest, publication enabled,
a malformed asset name and a release version.

The external consuming repository records d3689e1b for the bounded transport
and 9ba4ccb7 for the initial final-candidate transport. Final CI commit 397f4c87e97b1f187da967c58ee4dc7a6e725c22 includes the direct-ELF venv harness, early probe, general Dynatrace exclusion and matching RHEL capture.
Its transport sources are compared to all 19 canonical source identities in
the Debian capture. The RHEL capture identity is also recorded by Debian.

After retaining the passing build 170 capture, commit d8ff208df5638dd6bd3fadafeb3d2897b7d88b1c
removed the temporary validation pin and was pushed to the internal CI remote.
The exact snapshot asset was rechecked by its server SHA-1 and removed through
the asset API, which returned HTTP 204. The ordinary release pin remains 9.13.4.
The final archive remains in local ignored review storage and on the build
account for independent reproduction.

## Validation limits

The final shell lint reports 54 production scripts clean. Focused ShellCheck
also passes on the harness and consuming CI shell transport. The installer and
per-tool package-list diff against HEAD is empty. No numeric Python unit
coverage applies; the attempted ghog run found no pytest project.

Older relocation diagnostics still compare the trimmed archive with their fixed
inventory from the earlier archive. They report removed libbfd, libctf and
libmpc entries and tools/python/root/a.out. Those observations are retained
in CI; they are not hidden by the pipeline's SUCCESS status. This record's
closure verdict comes from the required closure capture's explicit aggregate.

The sqlite waiver remains active until item 6. Item 7 owns the rebuild and
payload refresh. The current acceptance neither publishes a release nor claims
universal host-free execution of every helper listed in the archive.
