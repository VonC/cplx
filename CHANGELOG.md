# Changelog cplx

<img src="wiki/assets/logo-cplx-transparent.png" alt="" height="90" align="right">

`cplx` aims to recompile Linux tools self-contained build or a static build environment, using `LD_LIBRARY_PATH`, and ignoring `/usr/lib` and `/usr/local/lib`

By using our own static libraries, compatible with the RHEL server version, we can get tools with the most up-to-date features and security patches. And we are no longer depending on the server system updates.

## [v0.27.0-SNAPSHOT unreleased] Packed for Two -

One toolchain archive, Debian and RHEL, offline venvs.

- No Venv in the Suitcase
  -- Ship the lock and wheels; build the environment on arrival.
- SQLite Comes Along
  -- A bundled database library joins the portable toolchain.

This release carries the toolchain from its RHEL build host to Debian CI
agents and deployment prefixes. Installation works without host rsync;
ELF relocation writes DT_RPATH while preserving the loader and wheel
trees, and the Python wrapper keeps shipped libraries out of host helper
commands. Archive gates check library resolution, version requirements
and provider identity, with acceptance and publication bound to the same
archive bytes.

Consumer applications can ship without venvs and reconstruct them at the
target path from a locked companion containing the selected wheels and
helpers. Offline synchronization produces readiness evidence and retains
release inputs for recovery. SQLite 3.54.1 is built as a cplx tool and
checked through Python against the expected provider. After a minor OS
upgrade, setup can reuse eligible dependency lists and mirrors while
keeping indexes and progress tied to the detected architecture.

Production acceptance remains required before the final release tag.

### Key changes (v0.27.0)

- **Portable runtime and archive checks**: rsync-free installation,
  forced RPATH relocation and the foreign-distribution Python wrapper
  keep the toolchain usable across prefixes. Closure, platform and
  publication checks bind acceptance to the exact tools archive.

- **Locked offline environments**: package applications without venvs,
  verify the release inputs, reconstruct the selected environment without
  downloads or builds, and retain the inputs for predecessor recovery.
  Consumers own service stop/start, supervision and health checks.

- **SQLite and package metadata**: build SQLite 3.54.1 from source, check
  its identity and capabilities through Python, and reuse eligible minor
  release metadata without substituting another server's package index.

### 🚀 Features (v0.27.0)

- *(pkgs)* Add sqlite to the python sandbox
- *(pkgs)* Key the package lists on RHEL 9.8
- *(verify)* Add the step 0 installer harness
- *(install_pkg)* Select and announce the copy engine
- *(verify)* Add the step 1 engine selection cases
- *(install_pkg)* Mirror without rsync, behind a destination boundary
- *(verify)* Add the step 2 mirror fallback cases
- *(install_pkg)* Deploy root files without rsync, behind a preflight
- *(verify)* Add the step 3 root-file deploy cases
- *(install_pkg)* Install without the host rsync, on a proven second engine
- *(v0.27.0)* Plan the forced-RPATH relocation pass and its oracle
- *(install_pkg)* Observe every walked ELF into one normalized tuple
- *(install_pkg)* Assign one case per walked ELF
- *(install_pkg)* Format the CPLX-ELF/1 records
- *(relocation)* Force RPATH so wheels resolve inside the prefix
- *(closure)* Fix the checker module topology
- *(closure)* Classify the archive search scope
- *(closure)* Declare the archive closure policy
- *(closure)* Parse and bind the config bundle
- *(closure)* Gate the checker on the bundle
- *(closure)* Read every shipped ELF once
- *(closure)* Refuse an unresolvable DT_NEEDED
- *(closure)* Run the subject phase in the checker
- *(closure)* Declare the archive entry points
- *(closure)* Read every version definition once
- *(closure)* Add the last three invariants
- *(closure)* Run every invariant in order
- *(closure)* Commit the declaration envelope
- *(closure)* Move the report out of the entry point
- *(closure)* Add the waiver outcomes
- *(closure)* Add the publication boundary
- *(closure)* Gate the toolchain packaging run
- *(closure)* Add the live observer
- *(closure)* Add the verification driver and bind publication to its evidence
- *(closure)* Add the pipeline delivery of the authoritative tools
- *(closure)* Add the D10 evidence and policy module
- *(packages)* Select curated minor metadata
- *(packages)* Publish guarded exact indexes
- *(packages)* Scope progress and forward resets
- *(packages)* Merge architecture minor fallback
- *(sqlite)* Add shared provider probe
- *(sqlite)* Check capability before packaging
- *(closure)* Bind Python 3.13.15 declaration
- *(python)* Merge `SQLite` support
- *(release)* Validate archive evidence
- *(d10)* Measure exact wheel consumers
- *(tools)* Add pinned platform acceptance
- *(tools-release)* Verify normal-pin adoption and coherent recovery
- *(tools)* Merge validated archive release
- *(sqlite)* Build SQLite 3.54.1 as a cplx tool
- *(python)* Require the exact bundled SQLite
- *(sqlite)* Merge the bundled `SQLite 3.54.1`
- *(deploy)* Verify release inputs and transport
- *(deploy-venv-sync)* Verify selected wheels
- *(deploy-venv-sync)* Reconstruct exact venv
- *(deploy-venv-sync)* Retain release inputs
- *(deploy-venv-sync)* Validate CI evidence
- *(deploy-venv-sync)* Bind qualified releases
- *(deploy)* Validate published CI observations
- *(deploy)* Bind native acceptance evidence
- *(deploy-venv)* Bound the evidence a deployment keeps
- *(deploy-venv-sync)* Integrate offline deployment
- *(toolchain)* Integrate Debian and RHEL support

### 🐛 Bug Fixes (v0.27.0)

- *(sanitize)* Drop the deployment account name from the anchors
- *(design)* Make a missing rpath input fail only the objects it was due for
- *(v0.27.0)* State the tested host-tool rule and which host answers which step
- *(setups)* Read single-quoted hrefs in the index
- *(pkgs)* Resolve version ambiguity instead of refusing it
- *(install)* Derive the prefix from the version built
- *(install_pkg)* Never write the shipped loader
- *(install_pkg)* Never write the running patchelf
- *(wrapper)* Unset the search path for helpers
- *(wrapper)* Fail closed on an unusable read
- *(wrapper)* Work on a foreign distribution
- *(echos)* Tolerate an unset FROM_UNIX
- *(pkg)* Prepare and preserve closure candidates
- *(closure)* Report runtime verification scope
- *(check)* Run ShellCheck through ghog
- *(closure)* Gate archives on runtime closure
- *(packages)* Complete RHEL fallback setup
- *(python)* Select source libpython for SQLite build check
- *(python)* Honor the promoted SQLite library path
- *(python)* Verify SQLite provider identity on overlay filesystems
- *(publication)* Retain uncertain commit outcomes
- *(release)* Bind publication to accepted bytes
- *(tools)* Remove staged compiler probe
- *(tools)* Normalize candidate verification evidence
- *(tools)* Align application verification fixtures
- *(tools)* Qualify deployed runtime boundaries
- *(packages)* Remove a payload past cpio's notices
- *(sqlite)* Pass the expected build to acceptance
- *(sqlite)* Verify the selected archive first
- *(deploy-venv-sync)* Preserve floating-point TOML settings
- *(install)* Point the pkg_tools wrapper at the cplx copy

### 🚜 Refactor (v0.27.0)

- *(install_pkg)* Open a source-safe seam above an explicit main boundary
- *(consumer)* Name the consuming application generically

### 📚 Documentation (v0.27.0)

- *(wiki)* Explain the three sandbox routes
- *(wiki)* Document the architecture key
- *(wiki)* List distribution python versions
- *(wiki)* Put explanations first in the index
- *(draft)* Define the v0.27.0 umbrella
- *(draft)* Fold develop#19 and #20 findings
- *(draft)* Fold develop#21 and #24 findings
- *(draft)* Open the rsync fallback topic
- *(v0.27.0)* Move the effort to a version folder
- *(v0.27.0)* Settle the rsync fallback requirement
- *(v0.27.0)* Retain the measurement evidence
- *(v0.27.0)* Settle the rsync fallback design
- *(v0.27.0)* Plan the rsync fallback work
- *(v0.27.0)* Retain the step 0 baselines
- *(v0.27.0)* Record step 0 completion
- *(v0.27.0)* Retain the step 0 code review transcript
- *(v0.27.0)* Retain the step 1 selection captures
- *(v0.27.0)* Record step 1 implementation
- *(v0.27.0)* Retain the step 1 code review transcript
- *(v0.27.0)* Retain the step 2 mirror captures
- *(v0.27.0)* Record step 2 implementation
- *(v0.27.0)* Retain the step 2 code review transcript
- *(v0.27.0)* Retain the step 3 deploy captures
- *(v0.27.0)* Record step 3 implementation
- *(v0.27.0)* Retain the step 3 code review transcript
- *(wiki)* Publish the copy engines and the host-tool contract
- *(v0.27.0)* Record step 4 documentation
- *(v0.27.0)* Retain the step 4 code review transcript
- *(v0.27.0)* Retain the step 5 acceptance evidence and its inputs
- *(v0.27.0)* Consolidate the measured mtime acceptance rule
- *(v0.27.0)* Complete the rsync fallback validation
- *(v0.27.0)* Retain the step 5 code review transcript
- *(draft)* Correct item 2 scope and inherit the residual
- *(v0.27.0)* Open the relocation rpath item
- *(v0.27.0)* Specify the RPATH relocation fix
- *(v0.27.0)* Retain the rpath review transcript
- *(v0.27.0)* Design the ordered ELF classifier
- *(v0.27.0)* Retain the design review transcript
- *(v0.27.0)* Retain the fifteen-round plan review transcript
- *(v0.27.0)* Record step 0 as implemented against measured evidence
- *(v0.27.0)* Decide the installer's permitted host-tool vocabulary
- *(v0.27.0)* Record step 1 completion with two-host measured evidence
- *(v0.27.0)* Retain the step 1 code review transcript
- *(v0.27.0)* Use the record's own emphasis style
- *(v0.27.0)* Consolidate the plan decisions and close its review round
- *(v0.27.0)* Satisfy the markdown linter in the plan review transcript
- *(cplx)* Correct the tool-version and umbrella records
- *(relocation-force-rpath)* Record step 2 validation
- *(v0.27.0)* Record the step 2 code review
- *(relocation-force-rpath)* Fix the trailer position
- *(relocation-force-rpath)* Record step 3 validation
- *(v0.27.0)* Record the step 3 code review
- *(relocation-force-rpath)* Locate the acceptance
- *(design)* Exclude the loader from the library set
- *(relocation-force-rpath)* Gate step 4 on what it owns
- *(v0.27.0)* Record the ownership boundary
- *(relocation-force-rpath)* Record the step 4 state
- *(v0.27.0)* Record the step 4 code review
- *(wiki)* Describe the forced rpath and its reach
- *(relocation-force-rpath)* Record the step 5 state
- *(v0.27.0)* Record the step 5 code review
- *(relocation-force-rpath)* Amend the acceptance criteria
- *(relocation-force-rpath)* Record the step 6 run and scope
- *(relocation-force-rpath)* Record the completed step 6 handoff
- *(relocation-force-rpath)* Write the resume note
- *(draft)* Complete the umbrella row for this item
- *(v0.27.0)* Record the step 6 code review
- *(v0.27.0)* Derive the wrapper foreign-distro draft
- *(v0.27.0)* Write the wrapper foreign-distro requirement
- *(v0.27.0)* Design the wrapper search-path scope
- *(v0.27.0)* Plan the wrapper foreign-distro steps
- *(v0.27.0)* Claim Debian for the wrapper fix
- *(plan)* Record pre-consolidation questions
- *(plan)* Record the four review rounds
- *(plan)* Consolidate the eight answers
- *(v0.27.0)* Document the RHEL and Debian targets
- *(v0.27.0)* Point every requirement at its hosts
- *(plan)* Bind the step 0 host and capture rules
- *(wrapper)* Record step 0 completion
- *(review)* Record the step 0 review rounds
- *(plan)* Name the step 1 command and capture
- *(wrapper)* Record step 1 completion
- *(review)* Record the step 1 review rounds
- *(plan)* Name the step 2 capture and command
- *(python-wrapper-foreign-distro)* Record step 2 validation
- *(review)* Record the step 2 review rounds
- *(plan)* Name the step 3 validation command
- *(python-wrapper-foreign-distro)* Record step 3 validation
- *(review)* Record the step 3 review rounds
- *(plan)* Split step 4 into the freeze and the handoff
- *(python-wrapper-foreign-distro)* Record the step 4 freeze
- *(review)* Record the step 4 review rounds
- *(plan)* Lowercase the step 4b identifier
- *(python-wrapper-foreign-distro)* Record step 4b validation
- *(review)* Record the step 4b review rounds
- *(plan)* Name the step 5 instrument and settle its writes
- *(review)* Record the step 5 review rounds
- *(python-wrapper-foreign-distro)* Record step 5 validation
- *(reference)* Qualify the repeated environment headings
- *(issue)* Record pre-consolidation questions
- *(draft)* Derive the toolchain runtime closure draft
- *(issue)* Consolidate the runtime closure clarifications
- *(review)* Record the runtime closure review rounds
- *(umbrella)* Settle D10 and the item 4 hand-offs
- *(design)* Record pre-consolidation questions
- *(markdown)* Repair list and file-ending defects
- *(closure)* Settle the runtime closure design
- *(plan)* Record pre-consolidation questions
- *(closure)* Settle the runtime closure plan
- *(closure)* Fix the step 0 preservation command contract
- *(toolchain-runtime-closure)* Record step 0 validation
- *(review)* Record the step 0 review rounds
- *(review)* Retire the item 3 step 4b exchange
- *(toolchain-runtime-closure)* Record step 1 validation
- *(review)* Record the step 1 review rounds
- *(toolchain-runtime-closure)* Record step 2 validation
- *(review)* Record the step 2 review rounds
- *(toolchain-runtime-closure)* Split the unreferenced finding
- *(toolchain-runtime-closure)* Record step 3 validation
- *(review)* Record the step 3 review rounds
- *(toolchain-runtime-closure)* Record step 4 validation
- *(review)* Record the step 4 review rounds
- *(toolchain-runtime-closure)* Correct the topology and the packaging premise
- *(toolchain-runtime-closure)* Record step 5 validation
- *(review)* Record the step 5 review rounds
- *(toolchain-runtime-closure)* Give the evidence record to the report module
- *(toolchain-runtime-closure)* Record step 6 validation
- *(review)* Record the step 6 review rounds
- *(closure)* Record the operator root deletion
- *(closure)* Document the checker and its scope
- *(toolchain-runtime-closure)* Split the acceptance into step 8 under Q14
- *(toolchain-runtime-closure)* Record step 7 validation
- *(review)* Record the step 7 review rounds
- *(closure)* Settle final acceptance contract
- *(closure)* Retain final candidate evidence
- *(toolchain-runtime-closure)* Record step 8 validation
- *(feature)* Record pre-consolidation questions
- *(architecture)* Settle minor fallback
- *(design)* Record pre-consolidation questions
- *(architecture)* Settle fallback design
- *(plan)* Record pre-consolidation questions
- *(architecture)* Settle fallback plan
- *(architecture-minor-fallback)* Record step 1 validation
- *(architecture)* Record step 1 code review
- *(architecture-minor-fallback)* Record step 2 validation
- *(architecture)* Record step 2 code review
- *(architecture-minor-fallback)* Record step 3 validation
- *(architecture)* Record step 3 code review
- *(packages)* Explain minor fallback and resume
- *(architecture-minor-fallback)* Record step 4 validation
- *(review)* Record step 4 code review
- *(feature)* Record pre-consolidation questions
- *(python-sqlite-support)* Record focused draft
- *(python-sqlite-support)* Settle requirements
- *(python-sqlite-support)* Record spec review
- *(design)* Record pre-consolidation questions
- *(sqlite)* Correct candidate closure requirement
- *(sqlite)* Consolidate six design decisions
- *(plan)* Record pre-consolidation questions
- *(sqlite)* Bound validation IO costs
- *(sqlite)* Consolidate implementation plan
- *(python-sqlite-support)* Record step 1 validation
- *(sqlite)* Record step 1 code review
- *(python-sqlite-support)* Record step 2 validation
- *(sqlite)* Record step 2 code review
- *(python-sqlite-support)* Record step 3 validation
- *(sqlite)* Record step 3 code review
- *(sqlite)* Record source retention verification
- *(sqlite)* Describe the verified execution route
- *(python-sqlite-support)* Record step 4 validation
- *(sqlite)* Retain the step 4 review
- *(feature)* Record pre-consolidation questions
- *(tools-archive-rebuild)* Record approved draft
- *(tools-archive-rebuild)* Settle requirements
- *(tools-archive-rebuild)* Record spec review
- *(design)* Record pre-consolidation questions
- *(tools-archive-rebuild)* Settle design
- *(tools-archive-rebuild)* Record design review
- *(plan)* Record pre-consolidation questions
- *(tools-archive-rebuild)* Settle plan
- *(tools-archive-rebuild)* Record plan review
- *(publication)* Require uncertain commit checks
- *(tools-archive-rebuild)* Record step 1 validation
- *(tools-archive-rebuild)* Record step 1 review
- *(tools-archive-rebuild)* Record step 2 validation
- *(review)* Record step 2 archive release review
- *(tools-archive-rebuild)* Record step 3 validation
- *(d10)* Record step 3 code review
- *(tools-archive-rebuild)* Record step 4 validation
- *(tools)* Retain step 5 candidate evidence
- *(tools-archive-rebuild)* Record step 5 validation
- *(tools-archive-rebuild)* Record step 5 review
- *(umbrella)* Decide lock-identical venv and add item 8
- *(relocation)* Define venv preservation
- *(tools)* Record step 6 acceptance gaps
- *(tools)* Retain step 6 review evidence
- *(tools)* Retain installer-only candidate
- *(tools)* Record review scope resolution
- *(tools-archive-rebuild)* Record step 5 validation
- *(tools)* Qualify RHEL with Python 3.13.15
- *(tools)* Record repaired RHEL checkpoint
- *(review)* Retain point 3 review context
- *(tools)* Bind Debian candidate evidence
- *(tools)* Record point 4 checkpoint
- *(review)* Retain point 4 review exchanges
- *(tools)* Bind final platform acceptance
- *(tools)* Retain step 6 review findings
- *(tools-archive-rebuild)* Record step 6 validation
- *(tools-release)* Retain publication and release-pin adoption evidence
- *(tools-archive-rebuild)* Record step 7 validation
- *(tools-archive-rebuild)* Retain step 7 code review
- *(wiki)* Document the bundled SQLite build
- *(debian-agent-tools)* Add the SQLite item
- *(sqlite-runtime-upgrade)* Define the SQLite item
- *(sqlite-runtime-upgrade)* Record step 1 validation
- *(sqlite-runtime-upgrade)* Record step 2 validation
- *(sqlite-runtime-upgrade)* Record step 3 validation
- *(sqlite-runtime-upgrade)* Record step 4 validation
- *(wiki)* Document the pre-extraction SQLite check
- *(sqlite-runtime-upgrade)* Scope the source check
- *(sqlite-runtime-upgrade)* Record step 5 validation
- *(sqlite-runtime-upgrade)* Record the code review
- *(feature)* Record pre-consolidation questions
- *(sqlite-runtime-upgrade)* Record pinned upgrade
- *(wiki)* State what the SQLite consumer decides
- *(debian-agent-tools)* Align item 9 loader text
- *(sqlite-runtime-upgrade)* Settle the requirement
- *(sqlite-runtime-upgrade)* Record spec review
- *(sqlite-runtime-upgrade)* Record step 5 validation
- *(feature)* Record pre-consolidation questions
- *(deploy-venv-sync)* Consolidate requirements
- *(design)* Record pre-consolidation questions
- *(deploy-venv-sync)* Consolidate design
- *(plan)* Record pre-consolidation questions
- *(deploy-venv-sync)* Clarify offline inputs
- *(deploy-venv-sync)* Consolidate reviewed plan
- *(deploy-venv-sync)* Record step 1 validation
- *(deploy-venv-sync)* Retain step 1 code review
- *(deploy-venv-sync)* Record step 2 validation
- *(deploy-venv-sync)* Record step 2 review
- *(deploy-venv-sync)* Add early pipeline probe
- *(deploy-venv-sync)* Record step 2 validation
- *(deploy-venv-sync)* Record step 3 validation
- *(deploy-venv-sync)* Record step 3b validation
- *(deploy-venv-sync)* Record step 3b review
- *(deploy-venv-sync)* Record step 4 validation
- *(deploy-venv-sync)* Record step 4 review
- *(deploy-venv-sync)* Decide phase 2 test scope
- *(deploy-venv-sync)* Preserve stage agents
- *(deploy-venv-sync)* Record step 5 validation
- *(deploy-venv-sync)* Record step 6 validation
- *(deploy-venv-sync)* Record step 6 review
- *(deploy-venv-sync)* Record step 7 validation
- *(deploy-venv-sync)* Record step 7 review
- *(plan)* Record pre-consolidation questions
- *(deploy-venv-sync)* Settle deployment plan
- *(review)* Retain deployment plan review
- *(deploy-venv-sync)* Set the 30-minute outage cap
- *(deploy-venv-sync)* Record incomplete step 8 review
- *(deploy-venv-sync)* Record step 8 amendment
- *(deploy-venv-sync)* Record the re-bootstrap deviation
- *(deploy-venv-sync)* Analyze the original-job delivery
- *(deploy-venv-sync)* Record the marker decision
- *(wiki)* Document the toolchain changes behind a consumer deployment
- *(wiki)* State the qualified Python versions of the tools archive
- *(v0.27.0)* Use generic account and host names in recorded evidence
- *(v0.27.0)* Cite the commits of the rewritten history
- *(deploy-venv-sync)* Record Step 8 as it stands on 2026-10-11
- *(deploy-venv-sync)* Record AC16 and AC17 closed on qualification
- *(deploy-venv-sync)* Record step 8 validation
- *(deploy-venv-sync)* Record the step 8 code review transcript
- *(deploy-venv-sync)* Record the Step 9 redirect and its progress
- *(wiki)* Explain a release that installs itself
- *(deploy-venv-sync)* Amend the step 9 scope
- *(deploy-venv-sync)* Record step 9 validation
- *(deploy-venv-sync)* Record the step 9 code review transcript
- *(deploy-venv-sync)* Separate release acceptance
- *(deploy-venv-sync)* Normalize completion status
- *(wiki)* Align release and deployment guidance

### 🧪 Testing (v0.27.0)

- *(install-pkg)* Add the step 5 acceptance suite and a calibrated oracle
- *(v0.27.0)* Measure the step 0 baseline from a real relocation run
- *(v0.27.0)* Enforce the host-tool contract in both directions
- *(v0.27.0)* Prove the classifier from both sides
- *(v0.27.0)* Retain the step 2 agent evidence
- *(v0.27.0)* Add the CPLX-ELF/1 contract corpus
- *(v0.27.0)* Prove the report contract from both ends
- *(v0.27.0)* Retain the step 3 agent evidence
- *(v0.27.0)* Run the tree, do not only count it
- *(v0.27.0)* Retain the loader survival probe
- *(v0.27.0)* Retain the build 110 agent evidence
- *(v0.27.0)* Assert the pages, do not grep for absence
- *(v0.27.0)* Close the fail-open faults and hand over
- *(v0.27.0)* Retain the RHEL acceptance sessions
- *(v0.27.0)* Retain the agent evidence for step 6
- *(v0.27.0)* Retain the scope correction run
- *(relocation)* Time each suite, reflink the copy
- *(relocation)* Retake the Debian captures
- *(wrapper)* Retain the pre-change wrapper bytes
- *(wrapper)* Bind the capture to what it measured
- *(wrapper)* Capture the step 0 baseline
- *(wrapper)* Add the step 1 scope suite
- *(wrapper)* Retake the step 0 capture
- *(wrapper)* Capture the step 1 scope rule
- *(wrapper)* Add the step 2 failure suite
- *(wrapper)* Retake the step 0 capture for step 2
- *(wrapper)* Retake the step 1 capture for step 2
- *(wrapper)* Capture the step 2 fail-closed rule
- *(wrapper)* Add the step 3 deployment suite
- *(wrapper)* Retake the step 0 capture for step 3
- *(wrapper)* Retake the step 1 capture for step 3
- *(wrapper)* Retake the step 2 capture for step 3
- *(wrapper)* Capture the RHEL no-regression run
- *(wrapper)* Freeze the harness and drop a coined word
- *(wrapper)* Retake the step 0 capture for the freeze
- *(wrapper)* Retake the step 1 capture for the freeze
- *(wrapper)* Retake the step 2 capture for the freeze
- *(wrapper)* Retake the RHEL no-regression capture for the freeze
- *(wrapper)* Publish the frozen harness identity
- *(wrapper)* Add the step 5 acceptance instrument
- *(wrapper)* Retain the Debian acceptance
- *(closure)* Measure the archive the closure rule describes
- *(closure)* Add the contract and fixture corpus
- *(closure)* Add the step 0 verification harness
- *(closure)* Retain the step 0 host captures
- *(closure)* Add the step 1 scope suite
- *(closure)* Retain the step 1 host capture
- *(closure)* Add the step 2 authority suite
- *(closure)* Retain the step 2 host capture
- *(closure)* Declare the step 3 fixture rows
- *(closure)* Add the step 3 subject suite
- *(closure)* Retain the step 3 host capture
- *(closure)* Declare the step 4 fixture rows
- *(closure)* Add the step 4 invariant suite
- *(closure)* Retain the step 4 host capture
- *(closure)* Add the step 5 gate suite
- *(closure)* Retain the step 5 host capture
- *(closure)* Add the step 6 suite and measure the fixture name window
- *(closure)* Retain the step 6 Debian capture
- *(closure)* Add the step 7 suite and two-host gate
- *(closure)* Retain the step 7 evidence and the trim measurement
- *(closure)* Bind acceptance to one candidate
- *(properties)* Record duplicate mirror fixture
- *(sqlite)* Capture isolated candidate acceptance
- *(d10)* Cover wheel identity and convergence
- *(tools)* Qualify candidate agent integration
- *(tools)* Cover step 5 package boundaries
- *(deploy)* Qualify isolated locked wheel sync
- *(deploy-venv-sync)* Cover selection drift
- *(deploy-venv-sync)* Cover venv lifecycle

### ⚙️ Miscellaneous Tasks (v0.27.0)

- *(senv)* Default python to 3.13.14
- *(vscode)* Accept the new doc vocabulary
- *(vscode)* Accept the ABI review vocabulary
- *(senv)* Load shared llm-shared doskey macros
- *(vscode)* Accept the review vocabulary
- *(vscode)* Accept the step 5 acceptance vocabulary
- *(config)* Ignore local agent settings
- *(config)* Add ELF and review spell words
- *(vscode)* Accept the ELF and relocation vocabulary in the dictionary
- *(vscode)* Accept the step 1 vocabulary in the dictionary
- *(vscode)* Accept the remaining review vocabulary in the dictionary
- *(vscode)* Accept the step 2 review vocabulary
- *(vscode)* Add unfailable to the dictionary
- *(vscode)* Add oneagentctl to the dictionary
- *(vscode)* Add SUBJECTID and theorised
- *(vscode)* Add five words this effort introduced
- *(markdownlint)* Allow a trailing space inside a code span
- *(vscode)* Spell the acceptance identifiers
- *(vscode)* Spell the runtime closure vocabulary
- *(markdown)* Add the shared gate entry points
- *(spell)* Accept the closure design words
- *(spell)* Accept the closure plan words
- *(vscode)* Accept the closure review vocabulary
- *(vscode)* Accept the closure review vocabulary
- *(vscode)* Accept the step 4 review vocabulary
- *(closure)* Declare the publication commands
- *(codex)* Add the agent instructions and the local execution exception
- *(closure)* Widen the host-tool contract to the verification path
- *(codex)* Tighten the agent instructions
- *(vscode)* Add the step 7 vocabulary to the dictionary
- *(editor)* Align shell and spelling checks
- *(editor)* Recognize unkeyed
- *(editor)* Recognize unshifted
- *(editor)* Accept SQLite planning terms
- *(editor)* Accept fstat in review notes
- *(editor)* Accept Python build terms
- *(editor)* Accept patchlevel in review notes
- *(closure)* Record Python 3.13.15 declaration source
- *(closure)* Retain the SQLite declaration source
- *(editor)* Accept nonpassing spelling
- *(editor)* Recognize wheel inventory terms
- *(editor)* Accept fixture terminology
- *(editor)* Recognize review terminology
- *(editor)* Recognize test lifecycle terms
- *(editor)* Accept CI evidence terms
- *(editor)* Extend tools release spelling vocabulary
- *(editor)* Spell the bundled SQLite terms
- *(git)* Ignore generated requirements file
- *(editor)* Extend documentation vocabulary
- *(editor)* Recognize network error name
- *(deploy-venv-sync)* Recognize console script name
- *(editor)* Allow unserialized
- *(editor)* Recognize tarfile term
- *(vscode)* Set inactive status bar color
- *(editor)* Set the active tab background
- *(editor)* Add deployment planning terms
- *(editor)* Add the unevidenced planning term
- *(editor)* Spell the deployment review terms

### 🔨 Build (v0.27.0)

- *(setups)* Move the package key to rhel 9.8
- *(senv)* Put shellcheck on the project path
- *(review)* Declare this repository's validation floor
- *(deploy-venv-sync)* Run selection checks

## [v0.26.0] - 2026-08-07 - Amnesia for the build home

install_pkg.sh re-anchors every path a binary memorized

- Fork no more
  -- pkg gains --add, a dispatcher, and thin project overlays
- The forge writes its manual
  -- a Diataxis wiki, a front page, and five theme logos

This cycle makes cplx packages portable. pkg.sh archives any $HOME folder
into ~/pkgs with a deterministic tar (sorted names, no gzip timestamp),
SHA1 dedup and a latest symlink; install_pkg.sh unpacks the newest archive
under any `--prefix` and re-anchors symlinks, text paths, `__pycache__` and
ELF interpreter/rpath (patchelf) there. Every tools archive now carries
its own installer, and both scripts survive their own relocation text
pass. The extension point keeps consuming projects on one shared copy:
repeatable `--add` items, a -- tar passthrough, the pkg dispatcher routing
`pkg_<target>` overlays, the pkg_tools front end, and a generalized deploy
of every archive root file.

The project also documents itself and refreshes its toolchain: a Diataxis
wiki (tutorials, how-to guides, reference, explanations) with a README
front page and the five theme logos; Git 2.52.0 and Python 3.13.9 in
senv; a per-tool env chain (.env_user sourcing .env_git and .env_python);
gpg prompts repaired through a self-relocating pinentry wrapper; and
install-side comfort: several source archives tolerated (newest wins with
a warning), rsync.sh for live-tree promotion, compare_file.sh to diff a
deployed file against its cplx source.

### Key changes (v0.26.0)

- **Packaging and relocation canon** pkg.sh and install_pkg.sh ship in
  cplx itself, reach ~/cplx/bin at setup and ~/tools/bin at promotion,
  and re-anchor a package under any prefix in four passes (symlinks,
  text paths, `__pycache__`, ELF interpreter and rpath).

- **Extension point and dispatcher**: consuming projects add archive
  items with --add, pass tar options after --, and plug a `pkg_<target>`
  overlay through the pkg dispatcher instead of forking pkg.sh;
  install_pkg.sh deploys every archive root file.

- **Wiki, toolchain and prompts**: the Diataxis wiki and README front
  page document the build model end to end; senv moves to Git 2.51.0
  and Python 3.13.7 with a per-tool env chain; the pinentry wrapper
  makes gpg passphrase prompts work in any installation prefix.

### 🚀 Features (v0.26.0)

- *(install)* Handle multiple src archives gracefully
- *(install)* Add script to compare files with cplx
- *(rsync)* Add script for robust tool version sync
- *(env)* Add Python environment setup and adjust Git
- *(pkg)* Ship packaging and relocation tools
- *(pkg)* Add extension point and dispatcher
- *(install_pkg)* Deploy any archive root file

### 🐛 Bug Fixes (v0.26.0)

- *(switchtool)* Force environment update after change
- *(env_python)* Standardize pip command and venv paths
- *(senv)* Non-fatal error when CPLX_TOOL unset
- *(install_pkg)* Survive the own relocation text pass
- *(certs)* Prompt through a pinentry wrapper
- *(switchtool)* Auto-create setup.properties
- *(bat)* Restore the project_dir export
- *(tools)* Correct senv.local.tpl defaults

### 🚜 Refactor (v0.26.0)

- *(python-env)* Make script more robust

### 📚 Documentation (v0.26.0)

- *(assets)* Add cplx and four theme logos
- *(branding)* Add logos to existing pages
- *(wiki)* Add Diataxis documentation set
- *(readme)* Add project front page
- *(wiki)* Make done-marker space explicit
- *(wiki)* Document packaging and relocation
- *(wiki)* Name the kind of build cplx does
- *(readme)* Surface relocation and build type
- *(wiki)* Document pkg extension and dispatcher
- *(wiki)* Document the git credential helper
- *(design)* Record the v0.26.0 cycle design
- *(wiki)* Close the v0.26.0 audit gaps
- *(wiki)* Record the switchtool exit code

### 🎨 Styling (v0.26.0)

- *(wiki)* Drop em dashes for plain punctuation
- *(readme)* Drop em dashes for plain punctuation

### ⚙️ Miscellaneous Tasks (v0.26.0)

- *(senv)* Update Git and Python version
- *(lint)* Add markdownlint configuration
- *(bin)* Record exec bit on packaging scripts
- *(certs)* Record exec bit on the pinentry wrapper
- *(workspace)* Add Workspace Halo logo
- *(vscode)* Sync Peacock color customizations
- *(release)* Notes follow senv defaults

## [v0.25.0] - 2025-08-21 - Python and Git on RHEL 9.6, add dev_workflow

This release introduces comprehensive support for **RHEL 9.6**, adding the necessary package lists and dependencies to build tools like Python and Git on this new platform.

The package management system has been significantly improved; it can now gather packages from multiple web addresses, producing a clean, sorted list of the newest available software.  
The installation process is more flexible, offering a new option to install single packages directly and running generic post-install steps for specific tools like `glibc` and `asciidoc`.  

The developer environment has been restructured by integrating a **`dev_workflow` submodule** for common setup logic, and adding numerous aliases for a smoother workflow.  
Build processes have also been corrected, with specific attention given to compiling Git and its documentation successfully on the new platform.

Git itself comes with a Git credential helper based on GPG2 for better security.

### 🚀 Features (v0.25.0)

- *(setup)* RHEL 9.6 packages
- *(setup)* Get_service_name for backward compatibility
- *(packages)* Support multiple package URL sources
- *(packages)* Sort and dedup downloaded pkg list
- *(uninstall)* Pkg-mgt glibc post-install, pit alias
- *(setup)* Add direct package install option
- *(senv)* Add irc alias for reconfiguring install
- *(rhel9.6)* Add RHEL 9.6 package gdbm and readline
- *(setup)* Package-download refresh noarch pkgs
- *(setup)* Implement package list reset command
- *(install)* Support generic post-install hooks
- *(setups)* Setup asciidoc config path for custom installs
- *(env)* Add customizable man command
- *(env)* Add base shell environment setup in ~/tools
- *(git-credential-helper)* Modernize credential setup

### 🐛 Bug Fixes (v0.25.0)

- *(md)* Add explicit IDs to markdown headings
- *(env)* Skip cc1 check without C++ compiler tools
- *(env)* Correct compiler detection for cc1
- *(env)* Include all single-digit .so versions in fnm alias
- *(install)* Expand dynamic linker search
- *(install)* Prevent rm error on missing file
- *(python)* Add zlib-dev to RHEL 9.6 package list
- *(setup)* Scp_package get cplx_path before failing
- *(install)* Handle malformed tar.gz archives
- *(install)* Set m4/perl tool environment paths
- *(setups)* Adjust pkgs Git build dependencies
- *(install)* Make sure install runs in source dir
- *(git)* Make pass helper reliable; add aliases
- *(changelog)* Add script for common typo and text fixes

### 🚜 Refactor (v0.25.0)

- *(error)* Give specific exit codes
- *(packages)* Refine ldd check
- *(setup)* Binutils post-install and git deps
- *(env)* Rename shell functions for clarity
- *(senv)* Integrate dev_workflow submodule

### ⚙️ Miscellaneous Tasks (v0.25.0)

- *(setup)* Update Python version in local senv tpl
- *(pkgs)* Add .keep file for package directory
- *(gitignore)* Ignore temporary URL file
- *(setup)* Refresh RHEL 9.6 x86_64 package list
- *(git)* Add tools/dev_workflow submodule
- *(git)* Ignore tmp files or folders
- *(tools)* Clean-up after dev_workflow integration
- *(changelog)* Fix typo

### 🔨 Build (v0.25.0)

- *(env)* Validate CPLX_TOOL is defined
- *(senv)* RHEL9 Git tool versions and support
- *(setup)* Add m4 and ninja; shell function syntax
- *(setups)* Add Git missing build dep for RHEL 9.6
- *(git)* Make Git documentation compile and install
- *(bat)* Use t_build scripts to dev_workflow dir.

## [v0.24.0] - 2025-08-05 - Git on CentOS 8

Check installation of Git on CentOS8

### 🚀 Features (v0.24.0)

- *(setups)* Define tool_name earlier in `.env`
- *(sh)* Support [l] in package URLs
- *(config)* Add essential template properties

### 🐛 Bug Fixes (v0.24.0)

- *(setups)* Remove autoconf2.7x from CentOS 8 deps
- *(setups)* Echos correctly display the caller name
- *(setups)* Use "mirrored" flag for install condition
- *(setups)* Correct file copies, glibc dependency
- *(setup)* Handle missing package file gracefully
- *(setup)* Ensure pkg dir exists before download

### 📚 Documentation (v0.24.0)

- *(md)* Explain glibc build include path issues
- *(txt)* Add autoconf2.7x to Git CentOS 8 deps

### ⚙️ Miscellaneous Tasks (v0.24.0)

- *(install)* Correct error code for missing ld
- *(setups)* Add cpp dependency for CentOS 8
- *(src)* Add trailing newline for packages_management.sh
- *(sh)* Add shellcheck and logging setup-packages
- *(git)* Update batcolors submodule
- *(git)* Ignore sensitive properties backups

### Fix (v0.24.0)

- *(setups)* Full path error in setup_packages.sh
- *(setups)* Handle missing dynamic linker in check_ldd

## [v0.23.0] - 2025-04-04 - make and glibc compilations

Following the incomplete compilation of glib (2.28 instead of 2.17 on RHEL 7.x, for running nodes 18), I need a make 4.x instead of 3.x.

Glibc compile, but does not install. Error or core dump on elf/sln.

### 🚀 Features (v0.23.0)

- *(make4)* Add GNU Make 4
- *(setups)* Add automake116 to the supported tools
- *(setup)* Use multiple URLs for package download
- *(install)* Introduce glibc wrapper scripts

### 🐛 Bug Fixes (v0.23.0)

- *(install)* Allow cleanup/install
- *(install)* Resolve bootstrap and automake issues
- *(env)* Check for glibc and make4 availability
- *(install)* Update return codes for errors
- *(install)* Enhance glibc build environment setup
- *(env)* CPLX_BIN means tool uses its name
- *(install)* Dynamic linker setting now conditional
- *(glibc)* Remove unnecessary linker flags
- *(packages)* Fix verbose parameter handling
- *(setups)* Update glibc packages for RHEL 7.9

### ⚙️ Miscellaneous Tasks (v0.23.0)

- *(setups)* Update CentOS 7.9 packages URLs
- *(setups)* Add libgcc and patchelf dependencies

## [v0.22.0] - 2025-04-01 -- Glibc, GCC and flex compilations

I need a more recent glibc than the one provided by the system (2.17 for RHEL 7.x), for running recent version of nodes.
But, to compile glibc 2.28, I need a gcc 4.9.4. Of course, RHEL has 4.8.5, so I also need a more recent GCC and flex.

This release has successfully recompiled gcc (using flex2, a more recent version of flex), and has produced wrapper scripts for all gcc-related command, so that gcc can be used by other tools (like the compilation of glibc) without setting the new gcc PATH and LD_LIBRARY_PATH: the wrapper scripts do that for you.

But glibc is still not compilable. Next step: compiling make 4.x (instead of the make 3.x provided by RHEL 7.x)

.env comes with install-related aliases (configure, build, install, package, deploy), and an alias to copy a tool source code (scps), complementing the existing scpe for environment setup files.

### 🚀 Features (v0.22.0)

- *(env)* Add scps alias to copy source files
- *(cplx)* Add glibc, gcc and flex2 to cplx services
- *(flex)* Add install scripts for flex
- *(install)* Add helper aliases for build process
- *(install)* Add `tool_version` to environment
- *(tools)* Add glibc to senv.local.tpl (wip)
- *(tools)* Add GCC 4.9.4 support
- *(install)* Call tool setenv if exists
- *(install)* Add `--force` to create_wrappers.py
- *(setups)* Add update_path_variables helper script

### 🐛 Bug Fixes (v0.22.0)

- *(install)* Correctly check for out-of-tree build
- *(install)* Update `ld_library_path` gcc `setenv`
- *(install)* Improve wrapper script usability
- *(install)* Correctly quote executable path in wrapper
- *(install)* Use absolute path for in gcc wrapper
- *(install)* Source echos and path update scripts
- *(install)* Gcc installation: ensure cc1 is in PATH
- *(glibc)* Correct glibc build process

### 🚜 Refactor (v0.22.0)

- *(install)* Env, improve install alias

### ⚙️ Miscellaneous Tasks (v0.22.0)

- *(git)* Update .gitignore, ignore `t/` folder
- *(aliases)* Add alias for build sources directory
- *(install)* Improve install script logging

### 🔨 Build (v0.22.0)

- *(packages)* Add missing TeX Live packages

## [v0.21.0] - 2025-03-24 -- Git cred helper and ssh wrapper

Test if GCM - Git Credential Manager can be used as is (no recompilation): no.

I tried:

- pass (using a trusted gpg2 key, with passphrase pre-registered to the
  `gpg-agent`: works with pinentry-curses, provided `GPG_TTY` is set to `$(tty)`)
- <https://github.com/languitar/pass-git-helper>, a python script, which uses a
 `~/.config/pass-git-helper/git-pass-mapping.ini`, but only matches `host`,
 not `user@host`

So implement a Git credential helper using GPG2 only (not pass), and it works
just fine: `src\install\env\git\bin\git-pass-helper.sh`.
It will create and trust a GPG2, with passphrase, said passphrase acting as a
local password. It will help encrypt a remote Git repository server token forced
the SSH GIT_LOGIN identified user.
(through an SSH forced command script, as described next)

Add an SSH wrapper which will set:

- `GIT_LOGIN` (from the `.ssh/authorized_keys` forced command parameter of `./tools/git/bin/sshwrapper.sh`)
- `GIT_AUTHOR_NAME` and `GIT_AUTHOR_EMAIL` (from `./tools/git/bin/sshgitwrapper.local`)
- `GIT_COMMITTER_NAME` and `GIT_COMMITTER_EMAIL` (in `./tools/git/bin/sshwrapper.sh`, after sourcing `sshgitwrapper.local`)

An sshe cplxgit will work, with a local PC `~/.ssh/config` of:

```log
Host cplxgit
  Hostname corp-host.prod.lux.ca-bank.com
  User gitea2
  IdentityFile ~/.ssh/cplxgit
  PreferredAuthentications publickey
  LogLevel ERROR
  #cplxgit_cd forced
```

The `#cplxgit_cd forced` will make the `sshe.bat` to open an SSH shell, and the
remote SSH forced command `sshwrapper.sh` will make the appropriate `cd` +
`source .env` (as well as set the GIT variables).

### 🚀 Features (v0.21.0)

- *(install)* Add gpg-restart script
- *(install)* Add git credential helper using `pass`
- *(install)* Use GIT_LOGIN for pass-git-helper
- *(setups)* Update git credential helper

### 🐛 Bug Fixes (v0.21.0)

- *(setups)* Set `GPG_TTY` and extend `PATH`
- *(install)* Update gpg-agent to use pinentry-curses
- *(install)* Sshwrapper must source `.env`
- *(install)* Improve GPG key generation and storage
- *(install)* Ensure gpg key has ultimate trust
- Git-pass-helper parsing fix
- *(install)* `git-pass-helper` use GPG2, not `pass`
- *(install)* Sshwrapper sourcing `.env` and init file
- *(install)* SSH set committer email and name

### ⚙️ Miscellaneous Tasks (v0.21.0)

- *(version)* Typos
- *(git)* Ignore PDF files

## [v0.20.0] - 2025-03-19 - libgpg-error

Needed by pinentry

### 🚀 Features (v0.20.0)

- *(libgpg-error)* Add libgpg-error service

## [v0.19.0] - 2025-03-19 - pinentry

Needed for GPG2 operation.  
Used by pass (the password storage utility)

### 🚀 Features (v0.19.0)

- *(pinentry)* Add pinentry tool support

### 🐛 Bug Fixes (v0.19.0)

- *(install)* Update environment variables for autotools

## [v0.18.0] - 2025-03-19 - Pass (password store) and GPG2

Needed for <https://github.com/languitar/pass-git-helper>
Goal is to store HTTPS credential encrypted.
Install everything to configure cplx own gpg2 keyring/secret-keyring
But it still need a pinentry-tty

### 🚀 Features (v0.18.0)

- *(pass)* Add pass (password store) tool support
- *(install)* Add support for tar.xz archives
- *(install)* Configure GNUPGHOME
- *(setups)* Add scripts and config for GPG key

### 🐛 Bug Fixes (v0.18.0)

- *(install)* Handle other build systems
- *(install)* Simplify pass install

### ⚙️ Miscellaneous Tasks (v0.18.0)

- *(git)* .gitignore includes `tar.xz` and `xz`
- *(packages)* Add cpp package to RHEL 7.9 setup

## [v0.16.0] - 2025-03-17 - libsecret, pkgconfig pc file and pkgs reinstall

- Where to store credentials?

  I have added the dependencies for libsecret and glib2 to work, and
  `~/tools/tool/sources/2.48.1/git-2.48.1/contrib/credential/libsecret$ make`: works

  But it does require a D-BUS session (which needs an X11 $DISPLAY
  and either a gnome-keyring or a KDE kwallet. So no vault backend for now.

- pkgconfig pc files are correctly updated during pkg installation process.

- you now can re-install all packages for a given tool: remove + install back.

### 🚀 Features (v0.16.0)

- *(install)* Add `short_package_name()` improve log
- *(setups)* Add force option to install packages cmd
- *(install)* Post-install updates pkg-config paths
- *(env)* Add alias for fix_package_pkgconfig_paths
- *(setups)* Build Git with libsecret
- *(install)* List installed/removed packages
- *(packages)* Rename lp to list_files_in_package
- *(install)* Reinstall pkg and reinstall all pkgs

### 🐛 Bug Fixes (v0.16.0)

- `pkg-config` path and `.pc` files
- *(setups)* Vim fix backspace
- *(setups)* Enhance pkgconfig path resolution
- *(install)* `remove_package` handles `.ori` files
- *(install)* Backup pkgconfig files before modification
- *(install)* Fix_pkgconfig_pc simplify path fixing
- *(install)* Multiple built packages during removal
- *(install)* Reinstall_package handle missing pkg name
- *(install)* Handle built-in packages in pkg-config
- *(install)* Handle root built-in pkg-config paths

### 🚜 Refactor (v0.16.0)

- *(env)* Rename lfpi to lfip, add rp and rap aliases

### ⚙️ Miscellaneous Tasks (v0.16.0)

- *(src)* Format comment

## [v0.15.0] - 2025-03-14 - curl dependencies compil, Git and openssl3

Start with libpsl and its own dependencies (libidn2, libunistring).  
Then install openldap, curl, libpsl and libunistring in Git: it works, and
`git-remote-https` is finally compiled.
Test also openssl3 (3.4.1) not yet included in Git.

Notes:

- Refactor the `install_functions.sh` to include the name of the tool in their
  name: easier to distinguish them.
- `CPLX_CONFIG_DONE` helps grep a string in a file (by default,
  'Creating Makefile' in '`config.log`') to better determine if a re-configure
  is needed.
- PATH now includes also `root/bin`, not just `root/usr/bin`.
- A built package is now deployed to tools/pkgs automatically, when `CPLX_BIN`
  is not 'true'. `find_package` knows to select the most recent package when it
  is a built one (as opposed to system ones, which should be unique)
- The alias `utm` allows to update a past tag, or recreate a missing one with,
  as message, the content of the version.txt at that past commit.  
  The script is `tools/git/update-tag-message(.bat/.sh)`.

### 🚀 Features (v0.15.0)

- *(setup)* Add libunistring
- *(install)* Implement package search and deploy
- *(install)* Deploy cplx-bin conditionally
- *(setups)* Add libidn2
- *(install)* Update PATH in install script
- *(install)* Add CPLX_CONFIG_DONE property
- *(install)* Add openssl3 support
- *(tools)* `utm` alias for update tag message script

### 🐛 Bug Fixes (v0.15.0)

- *(tools)* Pass tool name to add_tool.bat
- *(tools)* Correct libunistring check prefix
- *(setup)* Add cpp dependency for libunistring pkgs
- *(install)* Correctly link libunistring with cc1
- *(setup)* Handle empty CPLX_BIN variable
- *(install)* Configure and build template process
- *(install)* Update PERLLIB for perl modules
- *(tools)* Correctly place version query in add_tool
- *(install)* Add missing include path
- *(install)* Fix libpsl build on RHEL 7.9
- *(install)* Resolve curl build issues on RHEL7.9
- *(setups)* Correct Git dependencies and tools checks
- *(setups)* Openldap, correct openssl111 pkg name
- *(setups)* Update PATH env var
- *(install)* Build Git process reliability
- *(install)* Do not impose `-lssl`/`-lcrypto`
- *(install)* Openssl111 reconfigure message
- *(changelog)* Description message for range

### 🚜 Refactor (v0.15.0)

- *(install)* Rename tools install fct scripts

### ⚙️ Miscellaneous Tasks (v0.15.0)

- *(vscode)* Enable spell checking for plain text files

## [v0.14.0] - 2025-03-10 -- Openldap compilation, add_tool script

Since ldap uses openssl, it needs to use the right version of openssl
Openldap will need many dependencies to be recompiled, so we need to add many additional tools.
The add_tool script is used to add the necessary tools to the build environment.

### 🚀 Features (v0.14.0)

- Add and compile openldap to supported services
- *(curl)* Add curl installation scripts
- *(tools)* Add `add_tool` script
- *(tools)* Add interactive tool setup
- *(tools)* Add libpsl to senv.local.tpl
- *(setup)* Add libpsl to setup and env properties
- *(tools)* Update tool properties
- *(tools)* Handle binary/lib for new tools
- *(tools)* Add_tool manages source URL
- *(tools)* Enhance add_tool script with format detection
- *(install)* Add tool install scripts
- *(install)* Add configure, build, and clean functions
- *(tools)* Refactor resource creation in add_tool.bat

### 🐛 Bug Fixes (v0.14.0)

- *(setup)* Validate downloaded source size
- *(tool)* Set en var from tool section in add_tool.bat
- Handle CPLX_URL version placeholder

### 📚 Documentation (v0.14.0)

- *(tools)* Add_tool.bat comments

## [v0.13.0] - 2025-03-06 - Git compilation

Generate Makefile for the Git compilation
Compile Git.  
Still fails to include curl, so no git-remote-https generated.

### 🚀 Features (v0.13.0)

- *(setup)* Add git to senv.local.tpl
- *(setup)* Add Git installation support
- *(git)* Add Git compilation support
- *(git)* Implement Git wrappers
- *(install)* Add ic alias, CPLX_INSTALL_COPY_ONLY
- *(install)* Add git wrapper script
- *(install)* Handle system executables and symlinks
- *(setup)* Add `mtp` alias to mirror tool packages
- Improve linking of OpenSSL libraries

### 🐛 Bug Fixes (v0.13.0)

- *(install)* Add git dependencies for RHEL 7.9
- *(scripts)* Correct ffip alias definition
- *(install)* Remove unnecessary python removal
- *(setup)* Handle packages with underscore prefix
- *(git)* Improve git log alias
- *(install)* Correct library loading and linking
- *(install)* Remove unknown Git configuration options
- *(env)* Correctly handle return code of check_ldd
- *(openssl111)* Add zlib and cpp dependencies
- *(setup)* Update fnm alias

### 📚 Documentation (v0.13.0)

- *(md)* Add SSL documentation

### ⚙️ Miscellaneous Tasks (v0.13.0)

- *(git)* Bump version to 0.13.0-SNAPSHOT
- *(install)* Update sshgitwrapper local template

### 🔨 Build (v0.13.0)

- Add curl dependencies for Git on RHEL 7.9

## [v0.12.0] - 2025-03-04 - Compile OpenSSL 1.1.1w needed for Python on RHEL 7.9

Add openssl111 as a tool to compile
Upgrade python wrapper scripts to better handle venv (which copies its own set of python executables)
Add many functions to `packages_management.sh`, including the `install_package_from_name()` function, which means the `install_package` script is now obsolete, and removed.

### 🚀 Features (v0.12.0)

- *(setup)* Update OpenSSL tool name in props
- *(setup)* Add OpenSSL 1.1.1w support in props tpl
- *(setup)* Improve remote package handling
- *(setup)* Add package removal function
- Add aliases for package management
- *(setup)* Python wrapper script with symlinks
- *(setup)* Improve venv handling in python launcher
- *(tools)* Introduce command to get current tool name
- *(bin)* Add `get_full_package_name` command
- *(bin)* Add `lp` alias and `list_package` func
- Implement find_file_in_packages function
- *(bin)* Add `is_package_installed` function
- *(bin)* Add alias to install package from name
- *(bin)* Implement pkg mirroring and instal logging
- *(tools)* Add switchtool
- *(bin)* Add package list creation and check extension
- *(bin)* Implement logging for pkg mgt script
- *(packages)* Improve package installation check

### 🐛 Bug Fixes (v0.12.0)

- *(setup)* Improve CPLX URL handling in setup.sh
- *(build)* Correct OpenSSL linking order and libraries
- *(setup)* Add missing deps for Python on RHEL 7.9
- *(setup)* Ensure python3 exists before using
- *(python)* Remove obsolete openssl packages
- *(setup)* Error management in get_package_name
- *(setup)* Handle incomplete package downloads
- *(packages)* Fix partial installation detection
- *(bin)* Correctly handle file removal
- *(bin)* Handle multiple package candidate files
- *(env)* Use debug variable in aliases
- *(packages)* Handle built packages correctly
- *(openssl)* Use /usr prefix and lib64 for openssl 1.1.1
- *(bin)* Package naming now includes timestamp
- *(bin)* Improve built package detection
- *(bin)* Mirroring failed for built packages
- *(install)* Fix package name format
- *(bin)* Handle multiple /built/ package candidates
- *(bin)* Handle package lookup and flag checking
- *(bin)* Package management install means root folder
- *(setup)* Setup_packages handle small corrupted pkg
- *(setup)* Improve package installation process
- *(setup)* Openssl variables
- *(setup)* Handle remote built packages correctly
- *(setup)* `base_package_name` to extract base name
- *(setup)* Setup_packages.sh fix package size check
- *(pkgs)* Correct packages for Python RHEL 7.9
- *(python)* Disable UUID generation in Python build
- *(env)* Handle multiple arguments in aliases
- *(env)* Pass verbose var to `is_package_installed`
- *(python)* Remove uuid dependency on RHEL 7.9
- *(instal)* Python build fix uuid
- *(setup)* Remove install_package script
- *(bin)* Handle pre-installed package list

### 🚜 Refactor (v0.12.0)

- *(bin)* Improve package searching
- *(bin)* Extract `base_package_name` function
- *(bin)* Improve built package detection

### ⚙️ Miscellaneous Tasks (v0.12.0)

- *(md)* Markdown lint of doc.md
- *(tools)* Fix submodule initialization check
- *(bin)* Fix indentation in install_package
- *(setup)* Update python installation script
- *(git)* Update `.gitignore`

## [v0.11.0] - 2025-02-17 - Build Python with mpdecimal, add archive

Check if mpdecimal help for the Python decimal module
Add a package step to include all runtime dependencies and python wrapper script

### 🚀 Features (v0.11.0)

- *(install)* Rename archive to package in install scripts
- Enhance senv.bat with tool info
- Add mpdecimal package (remotely built: '_' prefix)
- *(env)* Add tools packages paths to `.env` file
- *(env)* Add alias to navigate to tool pkgs
- *(env)* Improve vimrc configuration with line #
- *(setup)* Support remote package installation
- *(env)* Compute tool name to `.env` file
- *(install)* Add install and package functions
- Get CPLX properties and add checks
- *(setup)* Setup.sh add arch and checks var to props
- Rename `cplx.properties` to `cplx.tpl.properties`
- *(setup)* Add `cplx.properties` to `.gitignore`
- *(setup)* Setup.sh creates cplx.properties
- *(setup)* Add `CPLX_BIN` property and `bin` directory
- Add Python 3 wrapper scripts
- *(setup)* Add root symlink in tool setup
- *(setup)* Create symbolic link for python.1 man page
- *(install)* CentOS 8 setup and doc
- Add mpdecimal package for RHEL 7.9 x86_64
- *(env)* Add `rgp` function to `.env` file

### 🐛 Bug Fixes (v0.11.0)

- *(setup)* Improve package extension handling
- *(setup)* Remove debug messages for skipped pkg
- *(setup)* Improve package installation flags
- *(install)* Link libmpdec and correct LDFLAGS
- *(nev)* Enhance fd function in .env file
- *(setup)* Always create `cplx.properties`
- *(setups)* Improve ldd check in install_package
- *(install)* Add CPLUS_INCLUDE_PATH to setenv script
- *(setup)* Simplify service name retrieval
- *(setup)* Get_service_name.sh service name detection
- *(setup)* Escape special characters in package names
- *(env)* Enhance senv.bat to remove done markers
- *(setup)* Use realpath for cwd in packages_management.sh
- *(mpdecimal)* Add missing dependencies for RHEL 7.9

### ⚙️ Miscellaneous Tasks (v0.11.0)

- *(docs)* Correct `-lgcc` to `-lgcc_s` in doc
- *(doc)* Address python test failures on Linux
- *(doc)* Python exploitation with pip upgrade

### Fix (v0.11.0)

- *(setup)* Add checks vars for Python and mpdecimal
- *(setup)* Setup.sh update `cplx.properties`

### Refactor (v0.11.0)

- `pkgs_dir` is actually `tools_pkgs`
- *(setup)* Rename archive to package
- *(setup)* Mutualize install and package functions

## [v0.10.0] - 2025-02-15 - Refactor, compile, and archive mpdecimal

Refactor: root is now per tool, not common to tools
mpdecimal: needed for Python to import _decimal module
archive: a tar.gz of the tool installed

Note: opening logs with VSCode no longer steam the focus of the current Windows which initiated the setup or installation.

### 🚀 Features (v0.10.0)

- *(env)* Add senvi alias for install functions
- *(install)* Improve Python environment setup
- *(env)* Add cdttc alias for current tool directory
- *(setups)* Improve install packages logging
- Remove env/tools and its unused .keep files
- Add mpdecimal and openssl to services to build
- *(setup)* Add setup script for remote server
- *(setup)* Get_the_latest_tag split in two steps
- Add download URL (CPLX_URL) in senv.local.bat
- *(setup)* Split get_the_latest_tag in two steps
- *(env)* Add mpdecimal and openssl services
- *(setup)* Improve setup.bat log display
- *(setup)* Improve setup.sh script, call remote setup
- *(install)* Create config symlink 'sources/current'
- Add steps.md to .gitattributes
- *(setup)* Add packages management script
- *(setup)* Enhance .env with package management
- *(setup)* .env source echos and install functions
- *(setup)* Improve directory structure for tools
- *(setup)* Setup script now adds install dir
- *(install)* Simplify current symlink update
- *(setup)* Add missing packages for CentOS 8 mpdecimal
- *(setup)* Support various source archive extensions
- *(env)* Add rg and rgi aliases
- *(bat)* Add scpe doskey command to senv.bat
- *(install)* Add make install, with mpdecimal
- *(tools)* Add `CPLX_ARCH_EXT` to `senv.local.tpl`
- *(install)* Add mpdecimal archive step

### 🐛 Bug Fixes (v0.10.0)

- *(python)* Adjust setenv error handling
- *(install)* Correct OpenSSL paths in Python installation
- *(install)* Missing Python deps for RHEL7 and CentOS8
- *(python)* Adjust OpenSSL paths and deps for CentOS 8
- *(install)* Update install docs and package lists
- *(setup)* Improve pkgs log file handling
- *(install)* Remove unnecessary symlink 'current'
- *(setup)* Add `tool/root`, check `CPLX_VERSION`
- *(setup)* Improve package lookup
- *(setup)* Setup_packages.sh update last one when OK
- *(setup)* Packages are logged and installed per tool
- *(install)* Adjust current symlink path for src
- *(setup)* Correct symbolic link path for ld
- Correct alias cds definition
- *(setups)* Add missing mpdecimal deps on CentOS 8
- *(install)* Enhance `LD_LIBRARY_PATH` and `LDFLAGS`
- *(install)* Correct installation prefix for tools
- *(mpdecimal)* Disable C++ support during build
- *(mpdecimal)* Improve mpdecimal build and clean

### 🚜 Refactor (v0.10.0)

- *(install)* Install_functions at tools level

### ⚙️ Miscellaneous Tasks (v0.10.0)

- *(md)* Start install section
- *(install)* Typo on comment
- *(doc)* Add mpdecimal source URL
- *(git)* Improve steps.md handling in Git attributes
- *(typo)* Correct hostname message in setup script
- *(doc)* Update version.txt

### Feat (v0.10.0)

- Setup.bat log display restore focus to window
- *(install)* Restore window focus after VSCode launch

### Fix (v0.10.0)

- *(src)* Use ln -nfs for symlinks
- *(setup)* .env shellchecks updates
- *(setup)* .env corrects root path
- *(setup)* Improve error handling in packages_management.sh

### Refactor (v0.10.0)

- *(setup)* Move setup file and improve structure

## [v0.9.0] - 2025-02-12 - Compile Python

Now that the install script works, and configure Python,
generating a Makefile, the goal is to compile it.  
It does, but cannot use hashlib based on openssl,
because CentOS/RHEL 7 use an old 1.0.2, instead of 1.1.1+

### 🚀 Features (v0.9.0)

- *(setup)* Skip commented lines in package list
- Prepare repeat/done steps test
- *(steps)* Improve step done management steps.sh
- *(install)* Add build step to installation
- *(env)* Add useful aliases to `.env`
- *(setup)* Add alternative RHEL 7.9 package URLs
- *(bin)* Add alias command wrapper
- *(steps)* Add steps_list and steps_list_one_step
- *(bin)* Improve alias command output, using color
- *(install)* Improve install script option parsing
- *(install)* Process options --clean and --configure
- *(env)* Add `fd` function to `.env` file
- *(env)* Improve file search functions
- *(env)* Symbol lookup, find and grep functions

### 🐛 Bug Fixes (v0.9.0)

- *(build)* Improve build.bat and senv.bat unset
- *(install)* Improve config.log check
- Install package do not fail on 'cp perm denied'
- *(python)* Add missing dependencies for RHEL 7.9
- *(install)* Fix CPLX_VERSION error msg install.bat
- Setenv() must have a version
- *(env)* Remove `export -f` from shell functions
- Remove unnecessary sys folder creation
- *(utils)* Steps.sh tests reset from the same file
- *(steps)* Exit early if steps_list_one_step fails
- *(setup)* Adjust bash command quote on step rep
- *(env)* Update alias command references
- *(install)* Add SSE4.2 flags to CFLAGS
- *(install)* Update `LDFLAGS` to include `-lgcc`
- *(install)* Pass all args to remote install script
- *(install)* Remove python after clean
- *(install)* Extend reconfigure options
- *(install)* Add bz2 pkgs for Python build RHEL 7.9
- *(install)* Ignore liboneagentproc in ldd check
- *(setup_packages)* Display skipped lines when resuming processing
- *(python)* Add missing dependencies for xmlsec1
- *(install)* Document liboneagentproc and openssl_hashlib

### 🚜 Refactor (v0.9.0)

- *(build)* Simplify cleanup routine

### 📚 Documentation (v0.9.0)

- *(md)* Compilation issues on RHEL 7.9
- Avoid cSpell on doc and CentOS packages details

### ⚙️ Miscellaneous Tasks (v0.9.0)

- *(md)* Non-blocking error __umodti3
- *(md)* Add modules to activate
- *(md)* Add LDFLAGS possible new options for compiler-rt
- *(setup)* Diable Code Spell Checker on pkgs list
- *(md)* Add doc on stdatomic.h
- *(md)* Add doc on bz2

## [v0.8.0] - 2025-02-10 - First installation step, configure works

Copy of the installation scripts.
Execution of a first installation step (unarchive source file, configure and make clean)
Check the installation log are copied back to the PC and opened in IDE

- A step can be reset.
- `cdp` is an alias to cd back to the project root folder.
- changelog is cleanup (no more double date before title)
- `sp` alias triggers a download, scp and unarchive of a rpm package from python_centos_8_x86_64.txt
- `i` alias triggers the scp of `install`, and `install_functions.sh`, launching the installation process

### 🚀 Features (v0.8.0)

- *(utils)* Add step reset functionality
- *(install)* Add installation scripts
- *(install)* Add installation scripts
- *(setup)* Make setup properties private
- *(setup)* Improve setup.bat error handling
- *(bat)* Senv.bat adds `hlsenv` alias
- *(install)* Installation script first implem.
- *(setups)* Rename project_path to cplx_path
- *(tools)* Add `CPLX_VERSION` to `senv.local.tpl`
- *(install)* Improve Windows installer
- *(install)* Add properties file loading
- *(setup)* Enhance setup.bat aliases
- *(setups)* Retrieve remote host architecture
- *(utils)* Enhance steps.sh with repeat/reset
- *(setup)* Improve setup.bat script
- *(setups,pkgs)* Add CentOS 8 packages list
- *(setup)* Add Python packages for CentOS 8
- *(setup)* Add CentOS and RHEL package URLs
- *(setup)* Add RHEL 7.9 x86_64 packages list
- *(setup)* Package synchronization reads pkgs file
- *(setup)* Add Python RHEL 7.9 x86_64 packages
- *(setup)* Start package synchronization code
- Update RHEL 7.9 x86_64 packages list
- *(setup)* Add package download functionality
- *(setup)* Add scp functionality for packages
- *(echos)* Add caller function to echoslog
- *(setup)* Add install_package script and integration
- *(setup)* Add CentOS/RHEL x86_64 packages folders
- *(setup)* Add .keep file for `root` tools directory
- *(setup)* Improve package installation
- *(setup)* Package installation mirroring and flag
- *(install)* Improve log file management
- Improve packages synchronization
- *(install)* Defined tools/tool symlink
- *(install)* Detects unclean ldd when inst package
- *(install)* Add config.log to local log file
- *(setup)* Add CPLX_SP_REPEAT env var to repeat
- *(setup)* Add install package post step
- *(install)* Enhance Python environment setup
- *(env)* Add alias to tail config log

### 🐛 Bug Fixes (v0.8.0)

- *(tools)* Remove date from changelog entries
- *(bat)* Change cdc alias to cdp or cdcp
- *(setup)* Project path from SSH config
- *(bat)* Build.bat is quiet after build.
- *(bat)* Move setup.properties copy logic in `senv.bat`
- *(install)* Install_functions.sh add quotes around variables
- *(install)* Get services
- *(install)* Get install tee output last line
- *(install)* Use install_functions.sh for tool installation
- *(install)* Improve archive detection in installer
- *(setup)* Improve architecture detection in setup.sh
- *(setup)* Use external URL for packages
- *(setup)* Improve package URL extraction
- *(setup)* Improve package URL extraction robustness
- *(python)* Remove unnecessary make commands
- *(setup)* Handle missing package URL property
- *(setups)* Correct setup.bat path handling
- *(setup)* Improve package download URL
- *(setup)* Add headers to avoid curl 403 errors
- *(setup)* Remove VSCode automatic opening
- *(setup.bat)* Improve error handling and logs display
- *(install)* Bat improve remote installation logging
- *(install)* Handle unzip/tar extraction failures
- Add root/usr/bin to PATH if missing
- Adjust LD_LIBRARY_PATH for python installation
- *(setup)* Delete pkgs.log before any call
- *(install)* Handle missing Makefile in clean
- *(install)* Handle config.log errors
- *(install)* Update aliases in .env file
- *(setups)* Add libdl to the ldd exclude list
- *(setup)* Add missing packages for gcc
- *(install)* Make sure to fail on ldd warning
- *(setup)* Improve ldd check in package installer
- *(install)* Add glibc-devel to Python CentOS 8 setup
- *(install)* Display parameters
- *(setup)* Adjust PATH environment variable in .env
- *(install)* Improve Python install logging
- *(setup)* Handle `.pc` files in ldd check
- *(install)* Avoid error in Python installation

### 🚜 Refactor (v0.8.0)

- *(setup)* Split copy_the_sources step

### 📚 Documentation (v0.8.0)

- *(md)* Add installation and complete setup steps
- *(md)* Add download packages list step

### ⚙️ Miscellaneous Tasks (v0.8.0)

- *(md)* CHANGELOG updated, trimmed and formatted
- *(bat)* Run.bat format loop
- *(git)* Add 'last' to .gitignore entries
- *(install)* Add missing packages for CentOS 8
- *(md)* Document build issues on CentOS 8
- *(setup)* Add openssl-devel dependency

### Fix (v0.8.0)

- *(bat)* Add trace logging to install and setup bat
- *(install)* Improve error handling in install script
- Add cpp package for CentOS 8

### Refactor (v0.8.0)

- *(bat)* Simplify senv.bat and init.bat

## [v0.7.0] - 2025-01-26 -- Download, then SCP tool sources to the remote server

Check `CPLX_TOOL` environment variable against declared services
Get the latest sources (with `-rc`, if `CPLX_TOOL_RC` is set), download and scp them.
Local `env` folder includes the right tree sources for the tools (python, git)

`src/setup/steps.md` steps ID have been updated to match their titles, using the alias `sfa`

### 🚀 Features (v0.7.0)

- *(setup)* Check services/tools to setup script
- *(setup)* Setup.sh scp sources
- *(setup)* Env keep `tools/sources` folder

### 🐛 Bug Fixes (v0.7.0)

- *(setup)* Update steps IDs to match their titles

## [v0.6.0] - 2025-01-26 -- SCP to remote host, senv updates, steps tests

`scp` all files needed for an `sshe` (I.e, "SSH Extended", an `senv` utility `ssh` wrapper) session.

- Include all rc files like a `.env` and `.vimrc`
- Include `get_env.sh` and `get_service_name.sh` in `bin/` to get the environment (dev,qal, ...) and service name (cplx, git_cpl, python_cpl, depending on where you are in the tree)

On senv updates, tools aliases (uv, uc and crel) are available even outside lsenv (no need to add `tools` to the `PATH`).
`senv.bat` and `init.bat` or `update-version.bat` no longer change the `cwd` (current working directory)

`steps` tests are using more expressive anchor names, enforced by the `sfa` alias, for `bash -c "./steps_format_anchors.sh $1"`

### 🚀 Features (v0.6.0)

- *(tools)* Cliff.toml skip CHANGELOG updates entries
- *(setup)* Initial files for env to scp
- *(bat)* Senv.bat add CHANGELOG.md content filter driver
- *(bat)* Tools aliases available outside lsenv
- *(bat)* Add senvle alias for local senv edit
- *(setup)* Robust environment transfer with tar
- *(utils)* Implement step management functions
- *(setup)* Repeat setup steps if CPLX_REPEAT_STEP is set
- *(setup)* Env Dynamically determine service in PS1
- *(env)* Add `tools_to_recompile` property
- *(setup)* Add `services` to properties file
- *(setup)* Enhance `.env` setup with properties and dynamic service
- *(setup)* Add env and service name retrieval scripts
- *(utils)* Improve repeat step handling
- *(tools)* Add setup shortcut and repeat step var

### 🐛 Bug Fixes (v0.6.0)

- *(tools)* Avoid adding description
- *(bat)* Senv.bat avoid ok msg on filter.changelog
- *(bat)* Avoid any cd on senv and init
- *(tools)* Update-changelog.bat avoid cd
- *(bat)* Remove old alias, ignore RELFORCE
- *(setup)* Setup.bat use _fatal properly
- *(setup)* Set `HOME` variable in `.env` file
- *(setup)* Move `gitconfig` to `.gitconfig` standard
- *(setup)* Copy `utils` and `echos` to remote server
- *(utils)* Improve step management and testing
- *(utils)* Improve steps management script and tests

## [v0.5.0] - 2025-01-21 -- CHANGELOG and tag updates with new version.txt format

Add `tools/git` script folder, to update old tag annotated messages: they not only includes the version and release title, but also the release description.
A `git tag -n v.0.4.0` will show all those informations.
Make sure `update-changelog.[bat/sh]` is able to regenerate the CHANGELOG.md from a given tag, not just from the last tag.
Update the CHANGELOG.md accordingly

### 🚀 Features (v0.5.0)

- *(tools)* Update-changelog.sh is able to regenerate CHANGELOG.md from a tag
- *(tools)* Update-tag-message updated tag annotation message
- *(tools)* Update-changelog.sh make_new_release means release header
- *(tools)* Update-version.bat release tag with date
- *(tools/git)* Update-tag-message.sh use date

### 🐛 Bug Fixes (v0.5.0)

- *(tools)* Update-version.bat fix multi-line release description
- *(bat)* T_build.bat echo fatal call path was incorrect
- *(tools)* Get-version.bat detects SNAPSHOT
- *(tools)* Update-version.bat git cmd must use -C
- *(tools)* Update-version.bat update version pattern
- *(tools)* Update-version.bat tag with version.txt
- *(tools)* Update-version.bat restore version
- *(tools)* Update-changelog.sh managed 'latest'
- *(tools)* Update-changelog.sh restore $1 in awk
- *(tools)* No need for double-quotes with date
- *(tools)* Update-version.bat avoid creating tag twice

### 📚 Documentation (v0.5.0)

- *(setup)* Describe SCP step

### ⚙️ Miscellaneous Tasks (v0.5.0)

- *(tools)* Remote old updateChangelog.sh
- *(git)* Update version.txt to include 0.5.0-SNAPSHOT release description
- *(git)* Version.txt update release goal

## [v0.4.0] - 2025-01-19 -- First step check SSH connexion, `update-changelog.sh` refactor

This first steps also uses the next properties and step features: the goal is to describe/document the steps in `src/setups/steps.md`, and to avoid making that step if the properties are already set (and memorize in `src/setups/setup.properties`).

This release also refactors the `CHANGELOG.md` generation, using `version.txt` both for the version and the release title/documentation.

### 🚀 Features (v0.4.0)

- *(bat)* Senv.bat add s alias for setup.bat
- *(bat)* Senv.bat add cdc to go back to project root folder
- *(echos)* Echoslog display exit status on fatal message
- *(echos)* Display script name as prefix on echos messages
- *(utils)* Steps and properties file management
- *(setup)* First step check SSH connexion
- *(tools)* Update-changelog(.bat/.sh) generate CHANGELOG.md
- *(alias)* Add uc local alias for update-changelog.bat
- *(tools)* Get-version.bat should also set project title and release notes
- *(tools)* Update-version.bat set or restore version and title in version.txt
- *(tools)* Update-version.bat use new version-title format with version.txt on SNAPSHOT

### 🐛 Bug Fixes (v0.4.0)

- *(tools)* Update-version.bat make sure to update changelog when doing a release
- *(tools)* Cliff.toml also skip chore commit for setting new release tag
- *(tools)* Update-changelog.sh clean up tmp files
- *(tools)* Get-version.bat now works
- *(bat)* Senv.bat unset project_version/title/release_notes
- *(tools)* Update-changelog.sh test range array size

### 📚 Documentation (v0.4.0)

- *(version)* Add version title and description in version.txt
- *(tools)* Cliff.toml add header for cplx project, with commit message on tags
- *(md)* CHANGELOG.md regenerated with more doc
- *(version)* Typo in release description
- *(md)* CHANGELOG.md updated

### ⚙️ Miscellaneous Tasks (v0.4.0)

- *(shell)* Add .shellcheckrc for external file directive
- *(git)* Ignore bak files

## [v0.3.0] - 2025-01-10 -- Setup initialization

Put in place the skeleton of a setup script (called by `build.bat`), which will executed multiple steps.
Since those are bash scripts, add an `echos` for colored log headers in bash.

### 🚀 Features (v0.3.0)

- *(bat)* Build.bat calls src\setups\setup.bat, fix exit status
- *(tools)* Senv.local.tpl declare SSH_CONFIG_ENTRY
- *(src)* Add Linux echos
- *(setups)* Add bat and sh scripts for setup

## [v0.2.0] - 2025-01-10 -- Refactor, use improved batcolors, with prefix, stack and multi-lines

A `call_echos_stack` in a script enable batcolors to print the script name.
Init.bat no longer calls/depends on senv.bat.
No more CHANGELOG update while in SNAPSHOT build.

### 🚀 Features (v0.2.0)

- *(tools)* Use batcolors with stacks
- *(bat)* Senv.bat stack before calling init.bat
- *(bat)* Senv.bat stack declares :call_echos_stack needed by batcolors stack
- *(tools)* Init.bat declares :call_echos_stack needed by batcolors stack
- *(tools)* Update-version.bat declares :call_echos_stack needed by batcolors stack
- *(bat)* Build.bat declares :call_echos_stack needed by batcolors stack
- *(bat)* Build.bat stack before calling senv, update-version or get-version
- *(tools)* Update-version.bat removes all [%~nx0] from _xx echos macros calls
- *(tools)* Init.bat no longer calls/depends on senv.bat
- *(bat)* Senv.bat is no longer called from init.bat, but calls it
- *(bat)* Senv.bat adds ^%USERPROFILE^%\go\bin to PATH if found
- *(bat)* Set CURRENT_SCRIPT when ECHOS_STACK not set in call_echos_stack
- *(bat)* Externalize release version management and changelog to tools/t_build.bat
- *(bat)* Senv.bat calls a senv.local.bat if exists
- *(bat)* Senv.local.tpl template for senv.local.bat (which remains private)
- *(tools)* No more CHANGELOG update while in SNAPSHOT build
- *(tools)* Reference new batcolors with prefix, callstack and pre/post macros
- *(bat)* Senv.bat adds uvf for forcing changelog check in update-version: FORCE_UC
- *(tools)* Update-version.bat does not stop if SNAPSHOT and FORCE_UC set
- *(bat)* Senv.bat add brel/br aliases for making release

### 🐛 Bug Fixes (v0.2.0)

- *(bat)* Build.bat additional cleanup
- *(bat)* Senv.bat extra space on local message
- *(tools)* Update-version.bat does not create snap on clean rel with 0 additional commit
- *(bat)* Senv.bat empty stack if not done already
- *(bat)* Senv.bat stack makes sure batcolors is unset last
- *(bat)* Build.bat trim build_dir trailing /
- *(tools)* Update-version.bat makes sure errorlevel is 0 before updating version.txt
- *(bat)* Senv.bat, init.bat cannot use CHECK_QUIET_PRJ macro with _xx echos macros
- *(bat)* Senv.bat unstack senv.bat after call to init.bat
- *(bat)* Senv.bat does not activate (ECHOS_STACK) stack by default
- *(tools)* UpdateChangelog.bat removes any nx0
- *(tools)* UpdateChangelog.bat add call_echos_stack
- *(bat)* Senv.bat fix unset, calls init.bat unset
- *(tools)* UpdateChangelog.bat specified working directory for git-cliff
- *(bat)* Build.bat silent mode for senv after a build (before post-processing)
- *(tools)* T_build.bat reset QUIET_PRJ on unset
- *(bat)* Add rem for other commands to add
- *(tools)* Migrate senv.local.tpl to tools
- *(tools)* Update-version.bat uses _post batcolors echos macro
- *(bat)* Senv.bat reset more variables in unset
- *(bat)* All.bat restore all_dir variable unset by build or run
- *(bat)* Senv.bat unset do not rely on possibly unset vars
- *(bat)* All.bat add missing eof after :unset function

### ⚙️ Miscellaneous Tasks (v0.2.0)

- *(git)* Ignore temp/tmp files
- *(git)* Update batcolors submodule SHA1 reference
- *(git)* Ignore temp file, generated by updateChangelog.bat
- *(git)* Update batcolors

## [v0.1.0] - 2024-12-31 -- Initial project template

Initial `senv.bat` with its aliases.
Focus on build.bat, which calls update-version.bat.

### 🚀 Features (v0.1.0)

- *(bat)* Senv/init/all/build/run
- *(bat)* Senv.bat prepare msg for local path preserved or set
- *(bat)* Senv.bat records path to path.ini between lsenv/fsenv
- *(bat)* Senv.bat set CHECK_QUIET_PRJ and CHECK_DEBUG_PRJ macros
- *(bat)* Senv.bat and init.bat use CHECK_QUIET_PRJ macro for quiet senv activation
- *(tools)* Get-version.bat initializes version.txt and set project_version
- *(tools)* UpdateChangelog.bat first implementation
- *(tools)* Update-version.bat calls updateChangelog.bat
- *(bat)* Build.bat calls update-version.bat
- *(bat)* Build.bat passes rel to update-version.bat
- *(tools)* Update-version.bat no more build check, if release always build
- *(tools)* Update-version.bat writes PRJ_REL_TITLE (if set) to CHANGELOG.md
- *(tools)* UpdateChangelog.bat uses PRJ_REL_TITLE (if set) as relTitle
- *(bat)* Build.bat creates a target/artifact-version file, fails if param prj_error
- *(bat)* Senv.bat add crel alias to cancel last release, only with lsenv (local)
- *(tools)* Update-version.bat no longer call build.bat
- *(bat)* Build.bat calls update-version, detect failed release and cancel it

### 🐛 Bug Fixes (v0.1.0)

- *(bat)* Senv.bat rsenv (restore) must delete path.ini
- *(bat)* Senv.bat removes Nexus-based aliases
- *(tools)* Init.bat does not define CHECK_DEBUG_x macro, senv.bat does
- *(bat)* Senv.bat references updateChangelog.bat only with local active (tools added to PATH)
- *(tools)* UpdateChangelog.bat must reference ../senv.bat
- *(bat)* Senv.bat reset additional env vars
- *(tools)* Update-version.bat errors and set has_been_called_from_update when called_from_build
- *(bat)* Build.bat restore senv before processing failed update-version
- *(bat)* Build.bat include build_msg in its banner
- *(tools)* Update-version.bat only restore version.txt, leave CHANGELOG.md untouched
- *(tools)* Update-version.bat reset_pre_release also delete tag after reset to previous commit
- *(tools)* Update-version check then generate CHANGELOG.md, even when it does not exist
- *(bat)* Build.bat fix params, set PRJ_REL_TITLE
- *(bat)* Make sure PRJ_REL_TITLE is reset
- *(tools)* Update-version.bat remove jar reference in fatal msg
- *(bat)* Build.bat skip params if called from update, parse and print params otherwise
- *(bat)* Build.bat must restore echos for params

### ⚙️ Miscellaneous Tasks (v0.1.0)

- *(vscode)* Workspace and settings
- *(git)* Attributes and ignore rules
- *(bat)* Add github.com/VonC/batcolors to tools\batcolors
- *(git)* Ignore path.ini generated by senv.bat for old(ori) PATH and project PATH
- *(tools)* Get-version.bat documentation
- *(tools)* Add comments to update-version.bat and updateChangelog.bat
- *(bat)* Build.bat documentation
- *(git)* Ignore old and ori extensions, old/ and tmp/ folders
- *(bat)* Build.bat add usage example using aliases
- *(git)* Ignore target/ folder
