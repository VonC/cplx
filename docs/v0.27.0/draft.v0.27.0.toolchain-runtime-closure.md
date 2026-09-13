# Ship a complete runtime closure in the archive

- Type: issue
- Umbrella: docs/v0.27.0/draft.v0.27.0.debian-agent-tools.md
- Umbrella item: 4, slug `toolchain-runtime-closure`
- Regroups: sub-tasks 1 and 2 of work item 3 (Q26) of the umbrella

## The umbrella entry this draft is derived from

> Type: Issue. Slug: `toolchain-runtime-closure`. Regroups sub-tasks 1 and
> 2 of work item 3 (Q26).

Sub-task 3 of that work item, making the root resolvable for dlopen'd wheels
through `--force-rpath`, is NOT part of this issue. It was umbrella item 2,
`relocation-force-rpath`, and it is already completed. Where the text below
says that something "belongs to requirement 2", it means that finished work.

## What this item lost to measurement, and why that is stated first

This item lost most of its first half to measurement, and it is worth stating
plainly because two earlier readings of the umbrella draft were wrong.
develop#19 listed `root/usr/lib64` alone and concluded `libgcc_s.so.1` was
missing; develop#24, listing all eight directories the relocation puts on the
rpath, found it shipping as `root/lib64/libgcc_s-11-20240719.so.1` under the
python root and the git root alike. There is no drop between payload extraction
and packaging to find and repair. Confirmed present as well: the four glibc
compat stubs and `libstdc++.so.6.0.29` in `root/usr/lib64`.

What the closure still owes is therefore NOT a missing library but a
GUARANTEE.

## The defect this issue fixes

Since glibc 2.34, `libpthread`, `libdl`, `librt` and `libutil` are merged into
libc, and the distribution ships tiny compat stubs for binaries that still
declare them. manylinux wheel extensions declare those stubs as `DT_NEEDED`
(pymupdf, develop#10), and their C++ ones need `libstdc++.so.6` with its
`libgcc_s.so.1` companion (pymupdf's `_extra`, develop#13). Whatever the loader
cannot resolve from the shipped root it fetches from the host `ld.so.cache`: on
Debian that mixes glibc 2.36 objects into the RHEL 2.34 process and dies
(`GLIBC_ABI_DT_RELR`, `GLIBC_2.36 not found`). RHEL targets never see it: their
cache serves compatible copies.

That asymmetry is what hid the Q26 family until CI ran on Debian, and it is why
a check that passes on the build account proves nothing about the agent.

## Sub-task 1: the packaging-time closure check

Add the packaging-time closure check listing the members the archive must
carry, OVER THE WHOLE RPATH rather than one directory, so a future drop cannot
ship silently.

develop#24 measured the current state rather than assuming it: over the whole
rpath, the four stubs (`libpthread.so.0`, `libdl.so.2`, `librt.so.1`,
`libutil.so.1`) and `libstdc++.so.6.0.29` sit in `root/usr/lib64`, `libgcc_s`
ships as `root/lib64/libgcc_s-11-20240719.so.1`, and no venv wheel resolves
anything host-side once the search list matches the runtime's.

ONE LIBRARY IS GENUINELY ABSENT, and it is the one this closure must gain:
`libsqlite3.so.0` ships nowhere in the root, confirmed on 2026-08-08 by
searching the live tree on the build account, while the RHEL servers carry
their own copy in `/usr/lib64`. An archive that compiled the extension without
shipping the library would pass on RHEL and fail on the agent. It arrives with
the umbrella's python-sqlite payload, and this sub-task is what makes its
arrival VERIFIABLE rather than hoped for: `libsqlite3.so.0` is among the
members the check enforces.

The wheel side needs nothing from this item. develop#24 showed every venv wheel
resolving inside the prefix, zero flagged out of 388 inventoried ELFs, once
each wheel carries the search list the runtime uses. That acceptance belongs to
the completed `relocation-force-rpath`; what belongs HERE is that the closure
check keeps it true after a rebuild.

BOTH PROBE READINGS MUST BE CONCLUSIVE when this is verified: a listing read
over the whole rpath, and a live trace that proves it looked at a venv process.
develop#20 answered "no host library loaded" for a run that had looked at
nothing, and that is the failure mode this requirement must not repeat.

## Sub-task 2: keep the snapshot coherent

Carry the coherence rule develop#14 taught: THE SHIPPED ROOT MUST BE ONE
SNAPSHOT where every version node a shipped library demands is defined by the
shipped libc.

The published 9.13.4 libc lacks the `GLIBC_2.35` version node that the current
RHEL `libgcc_s` demands, while the live build-account root has it: the archive
had diverged from the tree it was packaged from. At rebuild time, refresh the
sandbox RPMs (the stream mirrors roll), build against that ONE set, and check
that every version node demanded by a shipped library is defined by the shipped
libc.

The rule covers whole library FAMILIES, not only glibc:

- ship consistent pairs. develop#19: the root's libssl `3.5.1` demands
  `OPENSSL_3.x` nodes only its sibling libcrypto serves, and develop#24 finds
  that pair duplicated, one OpenSSL copy per tree, python and git;
- prune superseded generations at packaging. The 9.13.4 root carries two libbfd
  builds side by side.

ONE CAVEAT ON THE LIBSSL EVIDENCE, to check before spending effort on it. The
probe reports those `OPENSSL_3.x` nodes as missing while listing libssl as a
ROOT OBJECT, where no rpath applies and the host libcrypto answers. `import
ssl` passes on every run, so the pair is probably coherent already and those
eight lines are the same isolation artifact as the rest. `relocation-force-rpath`
is what settles it: re-probe now that every shipped library carries an rpath,
and only then decide whether this rule has anything to fix here.

## The open decision this item must settle: D10

| Decision | Options | State |
| --- | --- | --- |
| D10, the C++ runtime generation shipped in the root | (a) keep the GCC 11 `libstdc++.so.6.0.29` the platform provides, inheriting a one-node margin, `GLIBCXX_3.4.29` against an agent at `3.4.30`; (b) ship the GCC 12 generation from a toolset payload, so the archive absorbs a wheel set that moves past that node | OPEN, to settle inside this requirement |

develop#20 measured what develop#19 had missed: the agent serves
`GLIBCXX_3.4.30` and `CXXABI_1.3.13`, while the shipped `libstdc++.so.6.0.29`
is the GCC 11 generation topping out at `GLIBCXX_3.4.29`. Today's wheels
resolve the root copy, so their demands sit at or below it, but the margin is
exactly one node and the failure past it is a hard error rather than a
fallback, the develop#13 signature.

THE SAME LIMIT APPLIES TO THE RHEL 9.8 DEPLOYMENT SERVERS, whose own libstdc++
is that same GCC 11 build, so a wheel set that moves to `3.4.30` breaks
production as well as CI, and shipping the newer generation in the archive is
what would absorb it in both places.

(a) matches the deployment servers exactly and costs nothing now; (b) buys
headroom for both. MEASURE THE WHEELS' ACTUAL C++ DEMANDS during the rebuild
before choosing.

## Why this item is fourth

It is a packaging fix that can be validated by REPACKAGING THE CURRENT TREE,
without recompiling anything. Doing it before the expensive rebuild means that
rebuild produces a complete archive on the first attempt, instead of forcing a
second packaging round.

Depends on: umbrella items 1 and 2 only through the delivery order; technically
independent.

## Reference

The two hosts every claim here is settled on, and what each can prove, are in
[reference.environments.md](reference.environments.md). The asymmetry that
matters for this item: a closure gap passes on RHEL and fails on Debian, so the
agent is the only host that can refuse an incomplete archive.
