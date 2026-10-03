# Deployment environment acceptance

Step 7 qualifies one exact application candidate and its retained recovery inputs.
Passing the reusable cplx checks and passing the consuming application's deployment
checks are separate results. Both are required for completion.

## Responsibilities and inputs

cplx verifies supplied archives, creates the locked Python environment, checks
runtime readiness and provides integrity and recovery helpers. The consuming
application owns its deployment entry, CI pipeline, artifact acquisition,
credentials and target-specific acceptance adapters.

The application candidate consists of its archive, its actual deployment entry,
release input record and reconstruction companion. The companion contains the
pinned cplx helpers, uv, wheels and metadata. The tools/Python archive is a separate
qualified input. Bind all of these by checksum; a version label alone is
insufficient. The application's entry and the cplx environment helper have
different responsibilities and must have distinct, correct manifest entries.

The consumer may retrieve missing artifacts before invoking cplx. Supply and
verify the complete local set first, then deny remote services before
reconstruction. Keep retained release inputs separate from disposable caches.
Rollback must use the predecessor's retained inputs, including its own entry
and helper version. Do not download replacements during recovery.

The historical application release is needed only for the first-transition
recovery case: install a release that shipped its venv, upgrade to the candidate
that reconstructs its venv, then recover the older application offline. The
second recovery case uses a predecessor that already reconstructs its venv.

## Reusable regression checks

Run the cumulative checks in the native Linux environment documented in the
implementation plan:

```bash
bash docs/v0.27.0/verify.deploy-venv-sync.sh \
  --step 7 \
  --python /qualified/tools/python/bin/python3 \
  --app-repo /private/consumer-checkout
```

The acceptance-driver subprocess tests exercise process failure, missing
observations, stale identities and altered evidence. Their results are explicitly
marked as fixtures and do not qualify an application candidate.

## Native acceptance driver

Create a private candidate manifest using the operator publication schema:
`schema`, `identity`, `state`, `expires_at`, `record`, `files`, `ci_evidence`,
`coverage` and `predecessors`. Use absolute paths to retained regular files.
The identity is the release input record's SHA-256; state must be `retained`.
The release and combined CI evidence are validated before any adapter runs.
Predecessors may be `null` for independent checks; recovery and promotion require
both verified predecessor sets.

Create a private acceptance plan with explicit executable argument lists. For
example, this runs only the fresh-install case:

```json
{
  "schema": 1,
  "cases": {
    "fresh": {
      "command": ["/bin/bash", "/private/acceptance/fresh.sh"],
      "expected_exit": 0
    }
  }
}
```

```bash
bash docs/v0.27.0/acceptance.deploy-venv-sync.sh \
  --step 7 \
  --python /qualified/tools/python/bin/python3 \
  --candidate-manifest /private/acceptance/candidate.json \
  --acceptance-plan /private/acceptance/plan.json \
  --evidence-root /private/acceptance/results
```

The driver is an evidence orchestrator. An adapter must invoke and inspect real
commands on the declared target. The driver cannot establish runtime correctness
from arbitrary files supplied by an adapter. Review adapter code and its actual
execution evidence; successful process status alone is insufficient.

Each adapter receives `DVS_ACCEPTANCE_OUTPUT`, a fresh directory containing
`request.json`. That request names the run, case, exact candidate binding and
required checks. The adapter must write `observation.json` with exactly:

- `schema`: integer `1`.
- `run_id`, `case`, `candidate`: the request's exact values.
- `checks`: every requested check, each mapped to `path` and `sha256` for a
  nonempty regular evidence file inside this run's directory.

Evidence must contain observations of the named behavior: commands and statuses,
input digests, selected interpreter, readiness, inventories or live provider
traces as applicable. A copied request or a success string is not that evidence.
Negative adapters preserve the expected failing command status and additionally
prove rejection and lack of readiness. Their plan specifies the exact nonzero
status. An unexpected status, missing check or changed file fails the run.

The driver retains command output, start/end times, host identity, the observation
digest and `result.json`, including on failure. A successful subset creates an
acceptance summary with `complete: false` and the remaining cases. Never interpret
exit zero from a subset as completion of Step 7.

For an already published candidate, explicitly add `--published-candidate`.
Its CI evidence must retain `publish_status: published`; never relabel it as a
dry run. The observation validator applies the same candidate, revision, test,
coverage and inventory checks and records this mode in the acceptance binding.
This mode neither authorizes publication nor grants the separate operator
promotion gate: that gate continues to require non-publishing validation.
Publication receipts and exact-byte retrieval remain separate required evidence.
The `no-publication` case still needs its own executed suppression and override
checks; a published build cannot establish those outcomes.

## Required execution matrix

The executable case/check definitions are in
[acceptance_deploy_venv_sync.py](acceptance_deploy_venv_sync.py).

| Scope | Cases | Required result |
| --- | --- | --- |
| AC01 | `packaging` | Actual archive contents, canonical metadata and alias exclusion. |
| AC02-AC06, AC14 | `fresh`, `repeat`, `mirror-removed`, `wrong-host` | Exact local inputs reconstruct with empty caches, no target Git checkout and denied remote services; interpreter selection and readiness remain correct. |
| AC03-AC07, AC14 | `foreign-base`, `missing-inputs`, `stale-lock`, `missing-wheel`, `partial-sync`, `extra-distribution`, `wheel-tamper`, `bin-elf-tamper` | Deliberate failures are observed; invalid inputs do not become ready or trigger fetching/source builds. |
| AC08-AC09 | `debian`, `rhel`, `provider-failure` | Native runtime execution, heavy-wheel imports and conclusive live providers; original wheel ELF bytes and `$ORIGIN` preserved. |
| AC10, AC10a, AC10b | `ci-equivalence`, `ci-failures` | Both actual CI phases preserve revisions, commands, inventories, tests and coverage, and expose deliberate failures. |
| AC11 | `no-publication`, `wrong-qualification` | Validation cannot publish; mismatched qualification is rejected. |
| AC12 | `rollback-venv-free`, `rollback-shipped-venv`, `retention` | Both actual predecessor paths recover offline, and candidate inputs survive later builds. |
| AC15 | `changed-tools`, `serialization` | A changed archive with equal Python version requires revalidation; competing mutations of the same root are excluded. |
| AC02, AC13 | `consumer-delivery` | Actual consumer acquisition and invocation deliver the exact inputs and reach readiness; infrastructure evidence stays private. |
| Rollout | `promotion` | Authorized exact-byte publication, verified normal retrieval, offline deployment and rollback. |

Run independent cplx cases even when consumer acquisition is pending. Report
consumer invocation failures separately and retain their first useful diagnostic.
Changing an entry or companion creates a new candidate: obtain fresh combined CI
evidence and repeat affected qualification. Do not repair retained candidate bytes
in place or reuse their previous qualification for changed bytes.

## Qualification and publication

Collect conclusive results for the complete matrix and bind the operator's
qualification record to the candidate, tools, metadata, helper and predecessor
identities. Preserve raw results and their checksums. The acceptance summary is
not itself the operator's qualification record; that record uses the publication
helper's schema and must reference the completed native evidence.

Only after complete qualification and explicit publication authorization may the
private promotion adapter invoke the operator command. The runner additionally
requires `--publication-authorized` for that case. This flag gates execution on
authorization already obtained; it does not grant or record that authorization.
The adapter must retain the authorization evidence. Verify published receipts
and normal retrieval before the final offline deployment and recovery checks.

Record public verdicts through implementation-check in the
[validation plan](plan.v0.27.0.deploy-venv-sync.validation.md). Keep exact application
names, builds, hosts, paths and operational receipts in the private integration
handoff. Missing execution or publication authorization leaves Step 7 incomplete.
