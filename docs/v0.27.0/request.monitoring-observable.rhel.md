# Monitoring observable request for run `rhel-acceptance-20260827T114631Z`

**This request is drafted and DELIBERATELY NOT DESPATCHED.** The monitoring
criterion's standing disposition is `not-pursued`, decided by the human owner of
this effort on 2026-08-28 and recorded with its basis in
`verify.acceptance.rpath.rhel.session2.txt` section 4. This document is retained
as the record of what form 3 would have asked, so the option stays open to
anyone who later wants it. It is not gating and it is not waiting on anybody.

## Status

| Field | Value |
| --- | --- |
| drafted | 2026-08-27 |
| despatched | NOT SENT, by decision rather than by omission |
| decision | not-pursued, 2026-08-28, by the human owner of this effort |
| channel | the team operating the monitoring agent on the deployment estate |
| observable requested | form 3, written confirmation of attachment for one identified run |
| response | none, and none is expected, because nothing was asked |

## Why the other two forms could not answer it

Both were attempted on the target and neither is available to the deployment
account. The first statement here was WRONG in an earlier revision and is
corrected:

- **form 1**, a health or status query: the vendor control tool IS present at
  its standard path and is **not executable by this account**, which returns
  Permission denied. An earlier revision of this file recorded it as absent from
  the vendor's usual paths. That was a traversal failure read as an absence, and
  it is the same mistake this project already wrote into its own guidance after
  the shellcheck episode: an unavailable tool is a claim to verify, not a fact
  to record;
- **form 2**, an agent-side log or event: the log tree is present and its
  directories list, but of 8 files visible, 0 are readable by this account. The
  per-technology directories are world-writable and stay empty, because the
  preloaded object is an injection shim that loads the full agent only for a
  process it classifies as a monitored service. That was tested directly on
  2026-08-28 with a long-lived HTTP service bound to `127.0.0.1`: the shim
  mapped in, both threads were ours, the one socket was ours, no dynatrace
  mapping appeared beyond the shim, and no file anywhere under the agent tree
  ended up owned by this account. The avenue is closed by measurement.

## Why it is not pursued

The hazard this criterion existed to catch is answered on the mechanism. The
preloaded agent is statically linked, so `DT_RPATH` cannot change what it binds
because it binds nothing, and no path exists by which this change reaches it.
Chasing a vendor attestation for a risk already closed by construction was
judged not worth the coordination, and that judgement belongs to the human who
owns the effort rather than to the writer of this file.

## The message to send

> Subject: confirmation of agent attachment for one identified validation run
>
> We ran a validation deployment on a RHEL 9.8 host and need one confirmation
> for our acceptance record. We are not asking whether the product supports this
> configuration in general; a general statement of support does not answer what
> we need.
>
> Please confirm whether the monitoring agent attached to, and reported for, the
> specific process described below.
>
> - validation run identity: `rhel-acceptance-20260827T114631Z`
> - date and time: 2026-08-27, between 11:50 and 11:58 UTC
> - host: the RHEL 9.8 deployment host for the PDF splitter estate
> - process: a Python interpreter started from a relocated prefix under `/tmp`,
>   whose libraries all resolved from inside that prefix rather than from
>   `/usr/lib64`
> - what we observed locally: the agent is on `/etc/ld.so.preload`, it is
>   statically linked, and the loader trace shows its `init` running inside that
>   process, which exited 0
>
> What we cannot see from the host: whether the agent then attached to and
> reported that process to the backend. The deployment account cannot read the
> agent's own logs, so we cannot answer it ourselves.
>
> A yes or no against that run identity is all we need, and we will retain your
> answer verbatim as the evidence.

## Why this is asked at all

The relocation this validates changes which library directories a deployed
process resolves against, and changes the tag that governs precedence from
`DT_RUNPATH` to `DT_RPATH`. The local measurement shows the agent cannot be
affected by that change, because it is statically linked and binds nothing from
the prefix. That is a strong argument and it is not an observation of the agent
reporting, which is what the requirement asks for and what only the agent's
owner can see.

## If anyone ever does send it

Nothing here expires. Record the answer verbatim, set the despatched and
response fields above, and change the standing disposition in
`verify.acceptance.rpath.rhel.session2.txt` from `not-pursued` to `satisfied`
with the answer as its `monitoring-evidence:` value. The harness already parses
that token and will assert the evidence value is present, so the amendment can
be reversed by whoever obtains the observation without touching any check.

What is not acceptable is leaving this file as it stands and calling the
criterion satisfied.
