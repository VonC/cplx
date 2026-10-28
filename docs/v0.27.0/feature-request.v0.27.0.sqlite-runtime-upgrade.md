# Build the bundled SQLite from source

- Type: feature-request
- Version: v0.27.0
- Topic: sqlite-runtime-upgrade
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Test group: whole suite

## User story for the bundled SQLite

As the maintainer of a project that runs on the cplx toolchain python, I want
that python to load a current, identified SQLite build that carries the
WAL-reset corruption fix, so that the project can keep persistent data in the
standard-library `sqlite3` module on every supported target without depending
on the host's SQLite or its patch cycle.

As the toolchain maintainer, I want the build to be reproducible from verified
source, rebuilt Python to pick it up without stale reuse, and every stage to
prove that the loaded library is that exact build.

## Current SQLite provider entering item 9

Item 6 delivered `_sqlite3` by unpacking the distribution's `sqlite-libs` and
`sqlite-devel` payloads into Python's sandbox (D7 (b)):

- The provider is SQLite 3.34.1 from the el9 package, shipped as
  `tools/python/root/usr/lib64/libsqlite3.so.0.8.6` with its
  `libsqlite3.so.0` link, and floored by item 4's closure declaration.
- Its compile options are the distribution's, including `DISABLE_DIRSYNC`:
  SQLite then skips the directory sync after creating or deleting a journal.
- SQLite's WAL page documents a WAL-reset corruption race present from 3.7.0
  through 3.51.2, fixed in 3.51.3 and backported to 3.50.7 and 3.44.6. No
  backport was evidenced for the el9 3.34.1 package, and a vendor version
  number cannot prove one.
- Updating the host package would not change the provider: the toolchain
  python loads its own copy under the prefix, on RHEL as on the Debian agent,
  whose system SQLite the toolchain never uses.

A consuming project has since selected the standard-library `sqlite3` module
for persistent storage, so the bundled provider must change before that
project adopts it.

## Expected behavior of the bundled SQLite

- cplx builds SQLite as a library tool named `sqlite`, through the standard
  tool flow, from the newest stable upstream release selected by D12: 3.54.1.
- Python lists `_sqlite` in its package list and receives the deployed
  `sqlite` package in its sandbox; the two distribution payloads are gone from
  the list and from the sandbox.
- A change to the SQLite header or library in Python's sandbox forces a clean
  reconfiguration and rebuild of Python.
- The build, installed and operator probes reject any SQLite whose version,
  source id or compile options differ from the pinned expected build, and
  include a WAL smoke check.
- The packaged tools archive carries exactly one SQLite provider, and the
  relocated archive loads it on RHEL 9.8 and on the Debian 12 agent, from the
  python wrapper and from an application-style venv.

## Confirmed constraints for the SQLite build

These were settled with the user on 2026-10-26, from a source-backed
compatibility investigation of the exact Python 3.13.15 release archive:

- **Release**: SQLite 3.54.1, the newest stable release on that date, with the
  WAL-reset fix. CPython 3.13.15 requires 3.15.2 or later and states no upper
  bound; that absence is not proof of compatibility, which the CPython tests
  and the probes below supply. Prereleases, snapshots and the withdrawn 3.52.0
  are excluded. A later patch release is a reason to ask, not to switch.
- **Source identity**: the archive's SHA-256 and SHA3-256, the `sqlite3.c`
  SHA3-256 and the `SQLITE_SOURCE_ID` are pinned per version and verified
  before extraction.
- **SONAME**: `--soname=legacy`, so the library keeps the `libsqlite3.so.0`
  name that `_sqlite3` and the closure floor rely on.
- **Options**: parity with the replaced provider (FTS3, FTS4, FTS5, RTREE,
  SESSION, DBSTAT, COLUMN_METADATA, FTS3_PARENTHESIS, UNLOCK_NOTIFY,
  SECURE_DELETE, `TEMP_STORE=1`, `THREADSAFE=1`), without
  `DISABLE_DIRSYNC`. Extension loading stays unavailable to Python, which is
  built without `--enable-loadable-sqlite-extensions`.
- **Toolchain**: built inside the sandbox with its compiler and `--sysroot`;
  no host package is installed or replaced.
- **Rollback**: the previous tools archive and the previous Python package
  stay available; no published coordinate is overwritten.

## Acceptance criteria for the bundled SQLite

1. **AC1 source identity**: the `sqlite` build refuses an archive whose four
   pinned values differ, and refuses a version that has no pinned values. It
   checks the exact archive the installer selected before extracting
   anything from it, and checks a reused extracted tree again before
   configure and make.
2. **AC2 library shape**: the built and the installed library have SONAME
   `libsqlite3.so.0`, need `libm.so.6`, carry `DT_RUNPATH` and no `DT_RPATH`,
   and need no `GLIBC_` node above 2.34. Both links reach
   `libsqlite3.so.3.54.1`; no `libsqlite3.so.0.8.6` remains.
3. **AC3 compile options**: the expected-build file lists the 51 options the
   library reports; the parity options are present and `DISABLE_DIRSYNC` is
   absent.
4. **AC4 single provider**: Python's sandbox holds one real `libsqlite3.so*`
   file and its two links; removing a distribution payload removes all of its
   files.
5. **AC5 rebuild invalidation**: when the recorded header or library digest
   differs from the sandbox, Python's configured tree is retired and rebuilt;
   when the inputs cannot be read, the build stops with exit 26.
6. **AC6 probe**: the probe requires `--expected-sqlite`; a version, source id
   or option difference, a second provider beside the expected one, a failed
   WAL writer or a lost row fails the structured outcome, whatever the exit
   status of a wrapper.
7. **AC7 CPython tests**: `test_sqlite3` and `test_dbm_sqlite3` pass from the
   installed tree and from a relocated archive.
8. **AC8 RHEL archive**: the tools archive passes the closure gate; a fresh
   relocation and an upgrade over the previous archive both pass the wrapper
   probe and an application-style venv check, with no loader path and no text
   file left outside the prefix.
9. **AC9 Debian agent**: the same archive, fetched as a snapshot candidate with
   a verification bundle from a committed cplx revision, passes the wrapper
   probe, the CPython tests, a loader check that initializes nothing outside
   the prefix, and the application venv check on the Debian 12 agent.
10. **AC10 documentation**: the wiki explains why the toolchain builds its own
    SQLite, how to build and verify it, and the reference values, and the
    existing SQLite how-to pages state the new prerequisite and probe input.

## Debian acceptance environment for the SQLite candidate

The Debian 12 agent of the consuming project's pipeline runs the check. The
archive under test and the verification bundle are fetched by digest from a
snapshot repository; the probe and its expected-build file come from the
bundle, never from the archive under test. Publication stays off for the run,
and the temporary pipeline change is removed once the run is green.

## Delivery boundary of the bundled SQLite

- This item establishes the runtime prerequisite only. The consuming project
  still qualifies its own filesystem locking, concurrent reads, writes and
  checkpoints, process-kill recovery, disk-full behavior, reclamation and
  durability. A version check or a WAL smoke check is not that proof.
- Publishing the archive under a release coordinate and adopting it in the
  consuming project keep their own authorization gates.
- The item returns to the umbrella integration branch through the normal
  topic return. Two how-to pages it updates were introduced on item 8's
  branch, so their part of the documentation follows item 8 there.

## Requirement clarifications

- The implementation preceded this requirement under an urgent request. The
  requirement, plan and validation plan record the settled decisions and
  their evidence; no specification review ran.
- The WAL smoke check proves the provider's basic WAL behavior under
  concurrent writers, not the consuming project's workload.

## Code and evidence references for the bundled SQLite

- `src/install/env/sqlite/sqlite_install_functions.sh`: source checks,
  configure line, library checks.
- `src/setups/pkgs/sqlite/sqlite_rhel_9.6_x86_64.txt`: the compile set.
- `src/setups/env/bin/packages_management.sh`: complete payload removal.
- `src/install/env/python/python_install_functions.sh`: SQLite input stamp
  and reconfiguration.
- `src/install/env/python/sqlite_probe.py` and
  `src/install/env/python/sqlite_expected.txt`: the probe and its expected
  build.
- `tests/unit/sqlite_probe/test_sqlite_probe/test_sqlite_probe_tdd.py`.
- `docs/v0.27.0/verify.python-sqlite-build.sh`,
  `docs/v0.27.0/acceptance.python-sqlite-support.sh` and
  `docs/v0.27.0/verify.python-sqlite-acceptance.sh`.
- `wiki/explanation/why-the-toolchain-builds-its-own-sqlite.md`,
  `wiki/how-to/build-and-verify-the-bundled-sqlite.md` and
  `wiki/reference/bundled-sqlite.md`.
- [Implementation plan](plan.v0.27.0.sqlite-runtime-upgrade.md) and
  [validation plan](plan.v0.27.0.sqlite-runtime-upgrade.validation.md).

## Open questions for the v0.27.0 bundled SQLite feature request

The answer lines below record review recommendations, pending the user's
decision. They do not change the requirement or settle it by themselves. The
implementation preceded this requirement, so each recommendation says whether
the delivered behaviour already matches it or what evidence it would add.

### Q01: Which targets does "every supported target" cover?

The user story asks for the bundled SQLite "on every supported target", while
the acceptance criteria name RHEL 9.8 and the Debian 12 agent only. cplx keeps
Python package lists for RHEL 7.9 and CentOS 8 that carry no SQLite payload,
the `sqlite` tool and Python's `_sqlite` line exist for the RHEL 9 x86_64
family only, and a consumer could run the archive on another distribution
that meets the closure floor. Which targets does this requirement promise the
bundled SQLite on?

#### BBQ for Q01

A caterer promises "the same sauce at every venue", but tasted it in two halls
only. Does the promise cover those two halls, every hall the caterer has ever
served, or any hall with a working stove? In this picture: the sauce is the
bundled SQLite 3.54.1, the two tasted halls are RHEL 9.8 and the Debian 12
agent, the halls served before are cplx's other build targets, and a working
stove is a host that meets the archive's glibc floor.

#### Options for Q01

- Option A1: The RHEL 9 x86_64 build family and its two qualified consumers,
  RHEL 9.8 and the Debian 12 agent. Other build targets keep their current
  behaviour; other hosts that meet the closure floor are expected to work but
  are not claimed.
  - pro: Promises exactly what the acceptance runs prove.
  - pro: Matches the scope item 6 settled for SQLite support.
  - con: A consumer on another distribution has no qualified claim.
- Option A2: Every Linux target cplx can build, the RHEL 7.9 and CentOS 8
  sets included.
  - pro: One SQLite contract for every archive cplx produces.
  - con: Those targets build Python without SQLite today; the item would grow
    by two toolchains and their qualification.
- Option A3: Any Linux host that meets the closure floor, without a run per
  distribution.
  - pro: A broad claim at no extra run cost.
  - con: Claims behaviour no run observed; the Debian loader findings show a
    host can differ in ways the floor does not capture.

#### Recommended option for Q01 (with arguments for this choice)

Option A1: the requirement should claim what its acceptance proves. The user
story then reads "on both qualified targets", and a later target is a new
item with its own run. The delivered behaviour already matches.

#### Answer to Q01: option A1 (with reason why it must be accepted as the answer)

Option A1: it aligns the user story with AC8 and AC9, keeps the scope item 6
settled, and adds no work to a delivered item.

User decision: confirmed: Option A1, narrowed to the consuming project's two
environments: its RHEL 9.8 target server and its Debian 12 CI container image.

Decided by the user on 2026-10-27. The urgency of this item is to let the
consuming project use the standard-library `sqlite3` module in those two
environments, and nothing else. Every claim of the requirement is to be
narrowed to that scenario; the user's guidance applies to all of Q01 to Q15.

### Q02: What does "reproducible from verified source" require?

The second user story wants the build "reproducible from verified source".
That can mean that a rebuild from the same pinned archive yields the same
identified library (version, source id, options, library shape), or a
byte-identical file. It can also mean that the source must stay retrievable
if upstream moves or removes the archive. Which does the requirement ask for?

#### BBQ for Q02

A bakery promises to bake the same loaf again from the same sealed flour bag.
Is the promise the same recipe and the same tasting, the same loaf down to
every crumb, or also a spare bag kept in the cellar? In this picture: the
sealed bag is the source archive with its four pinned values, the tasting is
the identity and shape checks of AC1 to AC3, the identical crumbs are a
byte-identical library, and the cellar is an internal copy of the source
archive.

#### Options for Q02

- Option B1: A repeatable verified configuration: every build from the pinned
  archive with the sandbox toolchain either reports the expected source and
  configuration identity and library shape (AC1 to AC3) or is refused. Byte
  identity, a demonstrated second build and source retention are not
  required.
  - pro: Every build already enforces these checks; matches the delivered
    behaviour.
  - con: The checks prove the reported identity, not binary equality: two
    builds may differ in bytes, so a digest cannot prove that a rebuild
    equals the shipped library.
- Option B2: A byte-identical library across rebuilds.
  - pro: The strongest claim; a digest proves equality.
  - con: Needs build-path and environment normalization and a second build to
    prove it; no consumer need for it is stated.
- Option B3: Option B1, plus a retained copy of the source archive in an
  internal repository.
  - pro: A rebuild never depends on upstream availability.
  - con: Adds an upload and its gate; the pinned values already make any
    retrieved copy verifiable, and the deployed package stays for rollback.

#### Recommended option for Q02 (with arguments for this choice)

Option B1: the pins already make any copy of the archive verifiable, and the
probes check the reported identity a consumer depends on. The user story then
reads "repeatable from verified source to the expected source and
configuration identity", which claims no binary equality. Byte identity would
cost normalization work without a stated need, and retention can be a later
decision if upstream availability ever becomes a concern.

#### Answer to Q02: option B1 (with reason why it must be accepted as the answer)

Option B1: it gives "reproducible" a meaning every build enforces, without
claiming a binary equality no check proves, and without adding work the
consumer does not need.

User decision: confirmed: Option B1, narrowed to the consuming project's two
environments: the library loaded on its RHEL 9.8 target server and in its
Debian 12 CI container image comes from the pinned, verified source and
carries the expected identity.

Decided by the user on 2026-10-27. The user story drops the broader word
"reproducible" in favour of that claim; byte identity, a demonstrated second
build and source retention are not required.

### Q03: Is option parity a floor or the exact feature set?

The requirement keeps "parity with the replaced provider" and lists the
features that must stay. The 3.54.1 build also reports options the replaced
3.34.1 could not have, such as `ENABLE_MATH_FUNCTIONS` and
`ENABLE_PERCENTILE`, which come from the newer release's defaults. Is parity a
floor that newer defaults may exceed, or must the build match the old feature
set exactly?

#### BBQ for Q03

A new kitchen must offer "the same menu as the old one". Is that the old menu
at least, with the new oven's extra dishes allowed, or the old menu only, with
the extra dishes struck off? In this picture: the old menu is the replaced
provider's options, the new oven is SQLite 3.54.1, and the extra dishes are
default options such as the math functions.

#### Options for Q03

- Option C1: A floor: the listed features must be present and
  `DISABLE_DIRSYNC` absent; the release's other default options may be
  present, and every reported option is pinned in the expected-build file.
  - pro: Uses the defaults upstream tests most; matches the delivered build.
  - pro: Every extra option stays visible and pinned.
  - con: A consumer may start using a feature the previous archive lacks,
    which ties into rollback (Q09).
- Option C2: The exact set: disable every option the replaced provider did
  not report.
  - pro: The feature set does not change across the upgrade.
  - con: Departs from upstream defaults to recreate an old release's limits,
    a configuration upstream exercises less.

#### Recommended option for Q03 (with arguments for this choice)

Option C1: the requirement protects what consumers already rely on, the
listed features, and the expected-build file keeps every addition explicit.
Disabling newer defaults adds risk for no protection the floor lacks.

#### Answer to Q03: option C1 (with reason why it must be accepted as the answer)

Option C1: "parity" then reads "keeps every listed feature", which the
delivered build and AC3 already prove.

User decision: confirmed: Option C1, narrowed to the consuming project's two
environments: every feature it could use under the replaced provider stays
available on its RHEL 9.8 target server and in its Debian 12 CI container
image.

Decided by the user on 2026-10-27. The release's newer default options may
be present, and the expected-build file pins each of them, so none appears
silently; `DISABLE_DIRSYNC` stays absent.

### Q04: Must every reported option match, the compiler string included?

The probes refuse any SQLite whose options differ from the expected build.
`PRAGMA compile_options` also reports the compiler that built the library, so
a patch update of the sandbox compiler makes the probe refuse an otherwise
identical library. Is that refusal intended, or should only the options that
change behaviour be compared?

#### BBQ for Q04

A wine label lists the grape, the vintage and the name of the cellar master.
A new cellar master bottles the same wine. Should the inspector reject the
bottle because the label changed, or check only the grape and the vintage? In
this picture: the label is the option list the library reports, the grape and
the vintage are the behavioural options, the cellar master is the `COMPILER`
option, and the inspector is the probe.

#### Options for Q04

- Option D1: Every reported option must match, the compiler included; a
  compiler change is a reviewed edit of the expected-build file and a new
  qualification.
  - pro: A library from another compiler, not yet qualified, cannot pass as
    the expected source and configuration identity.
  - pro: Matches the delivered probe and the comment in the expected-build
    file.
  - con: A compiler patch update fails every probe until the file is edited
    and the archive is qualified again.
  - con: Compiler-string equality is still not binary equality.
- Option D2: Compare every option except the informational `COMPILER` line.
  - pro: A compiler update does not block an unchanged configuration.
  - con: A different compiler produces a different binary, which would pass as
    qualified without a review.
- Option D3: Compare only the listed parity options and the absence of
  `DISABLE_DIRSYNC`.
  - pro: The most tolerant check.
  - con: Limit and default changes would pass unnoticed.

#### Recommended option for Q04 (with arguments for this choice)

Option D1: the user story's "that exact build" then reads "the expected
source and configuration identity", which every stage checks. A compiler
change is rare in this sandbox; its cost is a reviewed edit plus a new
qualification of the archive, and that is the right moment to pay it.

#### Answer to Q04: option D1 (with reason why it must be accepted as the answer)

Option D1: the delivered probe enforces the complete comparison; this policy
requires review and requalification on change, so a compiler change becomes
a deliberate event.

User decision: confirmed: Option D1, narrowed to the consuming project's two
environments: the probe on its RHEL 9.8 target server and in its Debian 12 CI
container image accepts only the qualified library, compiler string included.

Decided by the user on 2026-10-27. Both environments install the library
prebuilt in the tools archive, so a compiler change reaches them only through
a new archive build; that build needs a reviewed edit of the expected-build
file and a new qualification before either probe accepts it.

### Q05: Does "single provider" cover Python's sandbox or the whole archive?

The expected behaviour says the tools archive "carries exactly one SQLite
provider", but AC4 checks Python's sandbox only, and the probe refuses a
second provider only beside the expected one. During Step 4, packaging found
a second `libsqlite3.so.0` in the Git root, from an orphan distribution
payload, and the closure gate refused it because its content differed. That
gate compares candidates per loader lookup name and accepts identical
content at several paths, so it proves a unique provider content per name,
not a single physical file. Which scope, and which kind of uniqueness, must
acceptance prove?

#### BBQ for Q05

A building must have one water main. The inspector checks the kitchen and
finds one pipe; nobody checks the garage, where an old pipe is still
connected. Another inspector checks every room but accepts two pipes as long
as they carry the same water. In this picture: the water main is the SQLite
provider, the kitchen is Python's sandbox, the garage is another tool root
such as Git's, the first inspector is AC4 with the probe, and the second is
the closure gate, which accepts identical copies under one lookup name.

#### Options for Q05

- Option E1: The whole archive, one physical file: packaging acceptance
  records an inventory of SQLite libraries across every tool root, showing
  one real library and links resolving to it; AC4 is widened to say so.
  - pro: Matches the expected-behaviour sentence literally.
  - pro: No tool root can hold a stale or redundant provider.
  - con: Needs evidence the closure gate does not give: an inventory of the
    qualified archive, which is pending.
- Option E2: Python's sandbox only, as AC4 states today.
  - pro: The smallest acceptance surface.
  - con: Leaves the expected-behaviour sentence unproven; a second provider in
    another root would pass acceptance.
- Option E3: The whole archive, one provider content identity: identical
  real-file copies may exist in several tool roots. An inventory of all
  SQLite libraries must show that every copy has the same content digest;
  different content anywhere fails acceptance.
  - pro: Allows redundant identical copies while excluding stale content.
  - con: Requires archive-wide inventory and digest evidence, which the
    per-lookup-name closure gate alone does not supply; that evidence is
    pending.
  - con: The sentence must change from "exactly one provider" to "one
    provider content identity".

#### Recommended option for Q05 (with arguments for this choice)

Option E1: the requirement promises one provider, and the Git-root finding
shows that a stray copy can reach the archive. E1 and E3 need the same
archive-wide inventory, which the closure gate does not supply; E1 keeps the
requirement's sentence as written, while E3 would weaken it to allow
redundant copies no tool needs. Until the inventory is recorded, AC4's
archive-wide part is a pending evidence obligation, not delivered coverage.

#### Answer to Q05: option E1 (with reason why it must be accepted as the answer)

Option E1: it keeps the requirement's literal promise and names the one piece
of evidence still needed to prove it.

User decision: confirmed: Option E2, narrowed to the consuming project's two
environments: Python's sandbox carries exactly one SQLite provider, the one
the standard-library `sqlite3` module loads on its RHEL 9.8 target server and
in its Debian 12 CI container image.

Decided by the user on 2026-10-27, replacing the earlier E1 recommendation.
The expected-behaviour sentence is narrowed to match AC4; no archive-wide
inventory is required. The consuming project starts Python with the shipped
library directories first, Python's own before every other tool root, so a
copy in another root is not the one `sqlite3` loads; the probe refuses any
loaded library other than the qualified one, and the closure gate refuses a
differing copy under the same lookup name at packaging.

### Q06: What counts as passing the CPython SQLite tests?

AC7 requires `test_sqlite3` and `test_dbm_sqlite3` to pass. The runs on the
installed tree, the RHEL relocation and the Debian agent each report 541
tests with 5 skipped, without naming the skipped tests, so the counts do not
show that each environment skipped the same tests for the same reason.
CPython 3.13.15
states no upper bound for SQLite, and an open CPython issue (gh-143263)
reports one test failing on a newer SQLite for one reporter. What must a run
show to pass?

#### BBQ for Q06

A car passes inspection with "five checks not performed". Is that a pass if
the five were radio tests on a car without a radio, or must someone know which
five they were? And if the brake test fails the way it fails on a known model
defect, is the car still roadworthy? In this picture: the car is the shipped
Python, the five checks are the skipped tests, the radio is a feature this
build leaves out such as extension loading, and the known model defect is an
open upstream issue.

#### Options for Q06

- Option F1: Zero failures and errors in every required environment (the
  installed tree, the RHEL relocation and the Debian agent). For each, the
  evidence names every skip with its reason, tied to the tested archive or
  build identity, and each reason must follow from the build's documented
  configuration or from the host; an unexplained skip stays unresolved. A
  failure that matches an open upstream issue still fails, unless the user
  waives it, and the waiver is recorded as an exception, not as a pass.
  - pro: A skip that hides a real gap becomes visible in every environment.
  - pro: A known failure is decided by a person, not absorbed silently.
  - con: Existing logs may not name the skips; any environment they do not
    cover needs a new run, the Debian agent included, or a documented
    equivalence justification.
- Option F2: Zero failures and errors; any number of skips.
  - pro: Matches the evidence already recorded.
  - con: A skip caused by a missing feature would pass unnoticed.
- Option F3: Option F2, and a failure that matches an open upstream issue is
  accepted as known.
  - pro: An upstream defect does not block the item.
  - con: Acceptance would rest on the triage of each failure, with no human
    decision recorded.

#### Recommended option for Q06 (with arguments for this choice)

Option F1: these tests are the main proof that CPython works with a SQLite
newer than any it names, so their skips should be explained wherever the
archive is qualified. A waiver keeps an upstream defect a human decision. The
named skips are a pending evidence obligation: existing logs may supply them;
otherwise the missing environments need a run or a justified equivalence.

#### Answer to Q06: option F1 (with reason why it must be accepted as the answer)

Option F1: it turns "pass" into a statement a reviewer can check in every
qualification environment, and states the evidence still to collect.

User decision: confirmed: Option F1, narrowed to the consuming project's two
environments: zero failures and errors on its RHEL 9.8 target server and in
its Debian 12 CI container image, with the five skips named and explained.

Decided by the user on 2026-10-27. A verbose run on 2026-10-28, from the
qualified archive installed over the consuming project's pinned archive on
RHEL 9.8, names them: four big-memory tests (`test_too_large_blob`,
`test_too_large_string`, `test_func_return_too_large_blob` and
`test_func_return_too_large_text`), which the CPython test runner skips
without a `-M` memory limit, and `test_uri_windows`, which requires Windows.
None follows from the SQLite build or the host distribution, so the Debian
run of the same archive and command, with the same 541 run and 5 skipped,
has the same skips. No failure needed a waiver.

### Q07: Which host-injected libraries may the Debian loader check exclude?

AC9 requires a loader check "that initializes nothing outside the prefix".
The Debian agent injects the platform's monitoring library into every process
through its loader configuration, so the check excluded it by the pipeline's
existing rule. Read literally, AC9 cannot pass on that agent. What may the
check exclude?

#### BBQ for Q07

A clean-room rule says "nothing enters from outside", but the landlord fits a
smoke detector in every room. Is the room clean when the only outside object
is the landlord's detector, which the experiment never touches? In this
picture: the clean room is the toolchain prefix, outside objects are libraries
loaded from the host, the landlord's detector is the monitoring library the
agent's loader configuration injects, and the experiment is Python with its
SQLite.

#### Options for Q07

- Option G1: Exclude only instrumentation the host injects into every process
  through its own loader configuration, named by an existing rule. Never
  exempt SQLite, Python or a library the toolchain's ELF files need, even when
  the host's injection configuration also names it. The evidence reports each
  exclusion; the agent's identities and paths stay in private evidence. AC9 is
  reworded to say so.
  - pro: Keeps the check meaningful on a real agent; matches the delivered
    run.
  - con: The rule must follow any change in the agent's injection.
- Option G2: No exclusion: the check runs where nothing is injected.
  - pro: The literal criterion.
  - con: Needs an agent without the monitoring library, which the consuming
    pipeline does not offer.
- Option G3: Exclude any library outside the prefix that is not SQLite.
  - pro: The simplest rule.
  - con: A host libc, libz or OpenSSL loaded in place of the prefix's would
    pass, which is the leak the check exists to catch.

#### Recommended option for Q07 (with arguments for this choice)

Option G1: the check exists to catch a toolchain library resolved from the
host. An injected library the toolchain never asked for is not that leak, as
long as the exclusion is narrow, named and reported.

#### Answer to Q07: option G1 (with reason why it must be accepted as the answer)

Option G1: it makes AC9 true as written for the run that passed, without
weakening what the check catches.

User decision: confirmed: Option G1, narrowed to the consuming project's
Debian 12 CI container image: its loader check excludes only the monitoring
library the agent injects into every process, under the pipeline's existing
rule, and never SQLite, Python or a library the toolchain's ELF files need.

Decided by the user on 2026-10-27. AC9 is reworded to name that exclusion,
which the recorded run already reports. The RHEL 9.8 target server needs
none: its check found no loader path outside the prefix.

### Q08: Which earlier archive must the upgrade start from?

AC8 requires "an upgrade over the previous archive" to pass. The evidence
used the previous archive on the build host, which carried Python 3.13.9. The
requirement does not say whether "previous" means the archive the consuming
project pins today, the last archive built, or every archive published since
SQLite support arrived.

#### BBQ for Q08

A furniture maker checks that the new shelf fits "the previous bracket".
Which bracket: the one in the customer's wall, the last one made in the
workshop, or every bracket sold since shelves existed? In this picture: the
shelf is the new tools archive, the bracket in the wall is the archive the
consuming project pins, the workshop's last bracket is the previous archive
on the build host, and every bracket sold is each archive since item 6.

#### Options for Q08

- Option H1: The archive the consuming project pins at qualification time,
  since that is the upgrade it will run. When its digest matches the
  predecessor already tested, the recorded upgrade evidence is reused; when it
  differs or is unknown, an upgrade over the pinned archive is qualified and
  its identity and results are retained.
  - pro: Tests the upgrade that will actually happen.
  - con: The evidence must name the pinned archive's digest, and a mismatch
    costs a new upgrade run.
- Option H2: The previous archive on the build host, whatever its
  publication status.
  - pro: Matches the recorded evidence directly.
  - con: May not be the archive a consumer upgrades from.
- Option H3: Every archive published since item 6.
  - pro: Covers late adopters.
  - con: Several runs for upgrade paths no consumer is known to take.

#### Recommended option for Q08 (with arguments for this choice)

Option H1: the upgrade check exists for the consumer's real upgrade. The
recorded upgrade started from an archive carrying Python 3.13.9, which the
requirement does not identify as the consumer's pin. Whether that evidence
counts is therefore pending: a matching digest permits its reuse, and a
different or unknown one requires the extra run.

#### Answer to Q08: option H1 (with reason why it must be accepted as the answer)

Option H1: it ties AC8 to the upgrade that matters and states both branches,
reuse on a matching digest or a new run otherwise, as conditional evidence
rather than delivered coverage.

User decision: confirmed: Option H1, narrowed to the consuming project's RHEL
9.8 target server: the upgrade starts from the archive the consuming project
pins, `tools.2026-09-18_220913.tar.gz`, SHA-256
`df7dff7d63964f3b6b655dc135080df11b5fb026753fe0b290b9abc7372fbe87`, which
carries Python 3.13.15 with SQLite 3.34.1.

Decided by the user on 2026-10-27. That digest differs from the predecessor
of the Step 4 upgrade, which carried Python 3.13.9, so the upgrade was
qualified again on 2026-10-28. Both installs exit 0. Afterwards Python's
sandbox holds only `libsqlite3.so.3.54.1` and its two links, the old
`libsqlite3.so.0.8.6` gone. The wrapper probe passed, and a venv created by
the pinned archive's Python, kept across the upgrade, loads the exact build
and passes the database and WAL checks. No loader path and no text file
remain outside the prefix. The Debian 12 CI container image relocates a
fresh archive on every run, so it has no upgrade to qualify.

### Q09: What does rollback promise for data written under 3.54.1?

The requirement keeps the previous archive and Python package for rollback.
That archive brings back SQLite 3.34.1, with its WAL-reset race and without
features 3.54.1 offers (math functions, newer SQL syntax). A database the
consumer wrote under 3.54.1 may use such features, or may simply be expected
to open under the older release. What must rollback guarantee?

#### BBQ for Q09

A family moves into a new house and keeps the old house's keys "for
rollback". The keys still open the old door, but the furniture bought for the
new house may not fit through it, and the old house still has its faulty
wiring. In this picture: the keys are the previous archive and Python package,
the new house is SQLite 3.54.1, the furniture is data written with newer
features, and the faulty wiring is the WAL-reset race of 3.34.1.

#### Options for Q09

- Option I1: Rollback restores the previous toolchain only, with its old
  defects and feature set. It promises nothing about databases written under
  3.54.1: many stay readable by 3.34.1, but one that uses a newer feature may
  not. The wiki states both risks, and the consuming project decides whether
  its data and application must stay compatible with the older release.
  - pro: The toolchain promises only what it controls.
  - pro: The consuming project already owns its data qualification.
  - con: A consumer that ignores the note may find rollback unusable for its
    data.
- Option I2: This item proves that a database written under 3.54.1 opens and
  passes an integrity check under 3.34.1.
  - pro: Rollback gains a data guarantee.
  - con: Holds only for databases that avoid newer features, which the
    toolchain cannot control.
- Option I3: Rollback is unsupported once the consumer writes data under
  3.54.1.
  - pro: A simple, honest rule.
  - con: Removes the only quick exit if the new runtime misbehaves.

#### Recommended option for Q09 (with arguments for this choice)

Option I1: what a rollback can preserve depends on how the consumer uses its
database, which the delivery boundary already leaves to the consumer. Naming
both risks in the wiki is enough for an informed decision.

#### Answer to Q09: option I1 (with reason why it must be accepted as the answer)

Option I1: it keeps the rollback promise true and leaves the data question to
the project that owns the data, with the risks named.

User decision: confirmed: Option I1, narrowed to the consuming project's two
environments: going back to its previous tools archive on its RHEL 9.8 target
server or in its Debian 12 CI container image restores the previous toolchain
only, with SQLite 3.34.1 and its known race, and promises nothing about a
database written under 3.54.1.

Decided by the user on 2026-10-27. The wiki explanation page states both
risks; whether the data must stay readable by the older release is the
consuming project's decision, as the delivery boundary already says.

### Q10: Must the previous release's verification bundle verify the new archive?

The consuming project verifies the tools archive with a verification bundle
from a committed cplx revision. The new probe requires `--expected-sqlite`,
and the new provider is `libsqlite3.so.3.54.1`, so the previous release's
bundle cannot verify the new archive. Is that break accepted, with archive and
bundle adopted as a pair, and how strictly must the bundle's revision match?
The Debian run used a bundle from a commit that was later reworded without a
file change, so its revision no longer exists on the branch, while its tree
does.

#### BBQ for Q10

A new lock comes with its own key, and the old key no longer opens it. Is it
enough to hand over the new lock and key together, or must the old key keep
working? In this picture: the lock is the new tools archive, the new key is
the verification bundle from an identified compatible cplx revision with its
expected-build file, the old key is the previous release's bundle, and the
handover is the consumer's adoption.

#### Options for Q10

- Option J1: A digest-pinned, compatible pair: adoption pins the archive and
  verification-bundle digests together. The bundle comes from an identified
  committed revision and contains the compatible probe and expected-build
  file qualified with that archive; documented tree- or content-equivalent
  revisions are allowed. The previous bundle need not verify the new archive.
  - pro: The trust anchor stays outside the archive under test, as in the
    Debian run.
  - pro: Matches candidate mode, which already pins both digests, and the
    recorded provenance of the Debian bundle.
  - con: The consumer must change both pins and its probe call at once.
  - con: An equivalence claim must be documented, not assumed.
- Option J2: The previous release's bundle must still verify the new archive.
  - pro: The consumer can upgrade the archive alone.
  - con: The previous probe cannot check the new build's identity, so its pass
    would prove nothing about 3.54.1.
- Option J3: The archive carries its expected-build file, so any bundle's
  probe reads it from there.
  - pro: The consumer passes no new input.
  - con: The archive would vouch for itself, which the Debian acceptance rule
    forbids.
- Option J4: A strict same-revision pair: the bundle must come from the exact
  commit recorded with the archive, with no equivalent revision allowed.
  - pro: The simplest provenance rule to state.
  - con: Stronger than an external trust anchor requires; a reword or rebase
    with unchanged files would force a new bundle and a new Debian run.
  - con: The recorded Debian run does not meet it, so adopting it would leave
    AC9 needing a new run.

#### Recommended option for Q10 (with arguments for this choice)

Option J1: a verification only means something when the expected build comes
from outside the archive, and the digests make the pair immutable. Exact
revision equality adds no protection the digests and a documented equivalence
do not give, and the delivered evidence already follows J1.

#### Answer to Q10: option J1 (with reason why it must be accepted as the answer)

Option J1: it states the compatibility break the delivery already has, keeps
the trust anchor where the Debian rule puts it, and records provenance
without demanding a revision equality no check needs.

User decision: confirmed: Option J1, narrowed to the consuming project's two
environments: it adopts the archive and the verification bundle as one
digest-pinned pair, the bundle coming from an identified committed cplx
revision; the previous bundle need not verify the new archive.

Decided by the user on 2026-10-27. The Debian run already follows this: its
bundle comes from a commit later reworded without a file change, and the
validation plan records that tree equivalence as its provenance.

### Q11: What does "a later patch release is a reason to ask" require?

The release constraint says a later patch release "is a reason to ask, not to
switch". The requirement does not say who notices a new release, whether
anything must watch for one, or what moving to it requires.

#### BBQ for Q11

A pharmacy stocks one batch of a medicine. When a newer batch appears, the
rule says "ask before switching". Who looks for new batches, and which checks
does a switch repeat? In this picture: the batch is SQLite 3.54.1, a newer
batch is a later upstream patch release, asking is a user decision, and the
repeated checks are the acceptance criteria.

#### Options for Q11

- Option K1: No automated watch in this item. The maintainer or a consumer
  raises a new release; a switch needs a user decision, new pinned values and
  expected build, and AC1 to AC9 again, Debian included. The how-to describes
  the procedure.
  - pro: No network dependency at build time; the decision stays human, as
    D12 requires.
  - con: An upstream fix is adopted only once someone notices it.
- Option K2: The build checks upstream for a newer release and warns.
  - pro: The maintainer learns of releases at build time.
  - con: The build gains a network dependency, and builds are rare.
- Option K3: A scheduled job reports newer upstream releases.
  - pro: Timely notice without touching the build.
  - con: New infrastructure outside this item's scope.

#### Recommended option for Q11 (with arguments for this choice)

Option K1: the item's job is a qualified runtime, and D12 makes every switch a
decision. Writing the switch procedure down makes "ask" actionable without
new machinery; a watch can be a later item if one is wanted.

#### Answer to Q11: option K1 (with reason why it must be accepted as the answer)

Option K1: it defines what "ask" sets in motion and keeps the item within its
scope.

User decision: confirmed: Option K1, narrowed to the consuming project's two
environments: no automated watch; moving to a later SQLite release is a new
user decision, with new pinned values and expected build, and a new
qualification on its RHEL 9.8 target server and in its Debian 12 CI
container image.

Decided by the user on 2026-10-27. The existing how-to already describes the
procedure: its first step pins a changed release, and the same steps build
and verify it.

### Q12: Does the item complete at the qualified candidate or at publication?

The delivery boundary keeps publication and adoption behind their own gates,
but does not say whether item 9 completes before them. The consuming project
can only adopt a published archive, and a rebuilt archive would not be the
one qualified on the Debian agent.

#### BBQ for Q12

A tailor finishes a suit and the client's fitting goes well. Is the job done
at the fitting, when the suit reaches the shop window, or when the client
wears it to the wedding? And must the shop sell the suit that was fitted, not
a new one cut from the same pattern? In this picture: the fitting is the
qualified snapshot candidate, the shop window is release publication, the
wedding is the consuming project's adoption, and the new cut is a rebuilt
archive.

#### Options for Q12

- Option L1: The item completes at the qualified candidate, with its review
  and records. Publication and adoption follow under their own gates and are
  recorded where they happen; publication uses the qualified bytes, matched by
  digest, and a rebuilt archive needs a new qualification.
  - pro: The item closes on what cplx controls.
  - pro: The digest rule keeps the Debian evidence valid for the release.
  - con: The consumer's need is met only once publication happens.
- Option L2: The item completes at release publication.
  - pro: The deliverable is adoptable when the item closes.
  - con: Ties the item to a gate the delivery boundary deliberately keeps
    separate.
- Option L3: The item completes once the consuming project adopts it.
  - pro: Closes only when the need is met.
  - con: Makes a cplx item depend on another repository's schedule.

#### Recommended option for Q12 (with arguments for this choice)

Option L1: it follows the separation the requirement already states and adds
the one rule the release needs: publish the bytes that were qualified. A later
rebuild, the umbrella's release preparation included, stays allowed, but its
new archive needs its own qualification before release; a rebuild of the same
version cannot inherit the earlier candidate's digest or runtime evidence.

#### Answer to Q12: option L1 (with reason why it must be accepted as the answer)

Option L1: the item can close on its own evidence, and the release cannot
drift from what the Debian run proved.

User decision: confirmed: Option L1, narrowed to the consuming project's two
environments: the item completes at the candidate qualified on its RHEL 9.8
target server and in its Debian 12 CI container image; publication and
adoption keep their own gates and use those qualified bytes, matched by
digest.

Decided by the user on 2026-10-27. A rebuilt archive is a new candidate: it
needs its own qualification in both environments before the consuming
project adopts it.

### Q13: Must the toolchain offer a `sqlite3` command-line shell?

The `sqlite` build produces the `sqlite3` shell, but the toolchain puts no
SQLite command on its path. An operator who wants to inspect the consumer's
database may then reach for the host's `sqlite3`, 3.34.1 on RHEL 9 with the
WAL-reset race, and write to a live WAL database beside the application.
Python 3.13 also offers `python -m sqlite3`, a shell on the bundled library.

#### BBQ for Q13

A workshop buys a new, safe ladder for its staff, but visitors still find an
old, faulty ladder by the door. Should the workshop hand out a second new
ladder, or point everyone at the staff one? In this picture: the new ladder is
the bundled SQLite, the staff are the consumer's Python processes, the faulty
ladder is the host's `sqlite3` 3.34.1, a second new ladder is a `sqlite3`
shell on the toolchain path, and the staff ladder is `python -m sqlite3`.

#### Options for Q13

- Option M1: The library only. The wiki names `python -m sqlite3` from the
  toolchain wrapper, which selects the bundled provider, as the way to
  inspect a database, and warns against writing to a live database with the
  host's shell.
  - pro: The same library as the application, with no new command.
  - pro: Matches the delivered tool.
  - con: Operators used to `sqlite3` must learn another command.
  - con: That shell still permits writes; it is not a read-only or
    concurrency-safety guarantee, and the workload risks remain.
- Option M2: Put the `sqlite3` shell built from the same source on the
  toolchain path.
  - pro: The familiar command, on the qualified library.
  - con: A new executable to ship, close over and check.
- Option M3: The library only, without guidance.
  - pro: No documentation work.
  - con: Leaves the faulty shell as the obvious tool.

#### Recommended option for Q13 (with arguments for this choice)

Option M1: the qualified library already has a shell through Python, so
naming it reduces the chance of reaching the host's runtime by accident. A
second executable would add closure and qualification work for a
convenience. Neither choice makes operator writes safe beside a running
application; that stays the consuming project's operating rule.

#### Answer to Q13: option M1 (with reason why it must be accepted as the answer)

Option M1: it reduces host-provider confusion at the cost of a wiki
paragraph, without claiming a safety guarantee a shell cannot give.

User decision: confirmed: Option M1, narrowed to the consuming project's two
environments: the toolchain ships the library only; on its RHEL 9.8 target
server, `python -m sqlite3` through the toolchain's python wrapper is the
named way to inspect a database, instead of the host's `sqlite3` 3.34.1.

Decided by the user on 2026-10-27. The wiki explanation page names that
shell, warns against writing with the host's shell beside the application,
and states that neither shell is a read-only or concurrency guarantee.

### Q14: Must a Python tree with no recorded SQLite inputs be rebuilt?

AC5 retires Python's configured tree "when the recorded header or library
digest differs". A tree configured before this item has no record at all, and
it is exactly the tree the first upgrade meets: its `_sqlite3` was built
against the 3.34.1 headers. Does "differs" include "never recorded"?

#### BBQ for Q14

A cook must remake a sauce when the recorded spice batch differs from the jar
on the shelf. An old sauce has no recorded batch at all: is it kept or
remade? In this picture: the sauce is Python's configured tree, the recorded
batch is the SQLite input record, the jar is the SQLite header and library in
the sandbox, and the old sauce is a tree configured before item 9.

#### Options for Q14

- Option N1: A missing record counts as a difference: the tree is retired and
  rebuilt. AC5 names absence explicitly in its rebuild condition and keeps its
  rule that unreadable inputs stop the build with exit 26.
  - pro: The first upgrade cannot keep the old headers.
  - pro: Matches the delivered behaviour and its fixture.
  - con: One extra rebuild for a tree that might have matched.
- Option N2: A missing record is written from the current inputs, and the
  tree is reused.
  - pro: No extra rebuild.
  - con: Records the new inputs over a build made with the old ones: the stale
    reuse the requirement exists to prevent.

#### Recommended option for Q14 (with arguments for this choice)

Option N1: an unrecorded tree is the most likely stale tree, and a rebuild is
cheap next to shipping a `_sqlite3` built against other headers.

#### Answer to Q14: option N1 (with reason why it must be accepted as the answer)

Option N1: it makes AC5 cover the case that matters most, which the delivered
build already handles.

User decision: confirmed: Option N1, narrowed to the consuming project's two
environments: the Python they load was rebuilt under that rule, where a tree
with no recorded SQLite inputs is retired and rebuilt and unreadable inputs
stop the build with exit 26.

Decided by the user on 2026-10-27. Both environments install Python
prebuilt from the tools archive, so neither runs the rebuild itself; AC5
names absence explicitly.

### Q15: Must the requirement address upstream CPython reports on this runtime?

The library is built with `THREADSAFE=1`, as the replaced provider was, so
Python reports `threadsafety` 3. An open CPython issue (gh-160699) reports a
crash when several threads execute on one shared connection. The report
describes CPython 3.15.1 with SQLite 3.53.4, and its confirmation CPython
3.14.9 with SQLite 3.53.1, both on Windows 11; whether it applies to CPython
3.13.15 on Linux with SQLite 3.54.1 is unverified. The default
`check_same_thread=True` refuses such sharing. Must this item address or
document upstream reports of this kind?

#### BBQ for Q15

A car maker publishes a notice that another model, in another country,
stalled when two drivers pressed the pedal at once; nobody has tried it on
this car, and the default seat setting keeps a second driver away. Should the
dealer mention the notice with what is known, test this car first, or say
nothing? In this picture: the notice is gh-160699, the other model and
country are the reported CPython and SQLite versions on Windows, this car is
the qualified runtime, two drivers are threads sharing one connection, and
the default seat setting is `check_same_thread=True`.

#### Options for Q15

- Option O1: Bounded documentation: the wiki lists the relevant upstream
  reports with the versions and platforms they describe, their evidence
  status for this runtime (unverified unless reproduced), and the reporters'
  avoidance pattern, one connection per thread, attributed as such. The build
  keeps `THREADSAFE=1`.
  - pro: The consumer learns of the report before designing its storage
    layer, without a claim beyond the evidence.
  - pro: No change to the qualified build.
  - con: The list must be kept current when the runtime changes.
- Option O2: Investigate applicability: a separate scope item tries to
  reproduce the report on the qualified runtime before any guidance or build
  change is decided.
  - pro: Replaces an unverified report with evidence for this runtime.
  - con: New work on a usage that is not the default, outside this item's
    acceptance.
- Option O3: No mention.
  - pro: No extra work.
  - con: A consumer that turns off `check_same_thread` gets no pointer to an
    open report.

#### Recommended option for Q15 (with arguments for this choice)

Option O1: the report concerns a usage the default refuses and versions this
runtime does not ship, so a build change is not justified and an
applicability study can wait for a consumer that plans to share connections.
Recording the report with its evidence status is enough for an informed
storage design.

#### Answer to Q15: option O1 (with reason why it must be accepted as the answer)

Option O1: a short, attributed note informs the consumer without claiming a
defect this runtime has not shown, and without reopening the qualified build.

User decision: confirmed: Option O1, narrowed to the consuming project's two
environments: a bounded, attributed note on gh-160699, with the versions and
platform it describes and its applicability to this runtime unverified; the
build keeps `THREADSAFE=1`.

Decided by the user on 2026-10-27. The wiki explanation page carries that
note, with the default `check_same_thread=True` and the reporters'
one-connection-per-thread pattern.
