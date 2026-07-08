# Checkpoints and resume

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

A cplx run crosses a proxy, public mirrors, an SSH link and a compile
farm of exactly one machine. Something *will* fail mid-way. The design
answer is that every long operation is checkpointed, and every command
is a resume.

## Three checkpoint stores

| Store | Granularity | Cleared by |
| --- | --- | --- |
| `src\setups\steps.md` done markers | pipeline step | `s <step>`, `s r_<step>`, `CPLX_REPEAT_STEP`/`CPLX_RESET_STEP` |
| `src\setups\pkgs\<tool>\last` | one package in the dependency list | `sp reset`, `s package reset <line>` |
| artifacts on disk (archives, flags, timestamps) | file | deleting the artifact, or the `>` / force switches |

The first is explicit state, the second a cursor, the third is
[evidence](anatomy-of-a-build.md): downloads are skipped when the file
exists, scp when the remote copy exists, package installs when the
`.installed` flag exists, compiles when the check artifact is fresh.

## Why the step file is Markdown

`steps.md` is simultaneously the documentation of the pipeline and its
state: a human reads the plan, the runner reads the checkpoints, and
both are the same headings. The cost — checkpoint noise in version
control — is neutralized by a git textconv that strips the
` (done: ✅)` markers from diffs. The step tree also gives resume its
shape: finishing the last child marks the parent done; repeating a
parent re-opens its children but not its siblings.

## Resume as the default verb

There is no `--resume` flag anywhere because resuming is not a mode:
`s`, `sp` and `i` always pick up from the last evidence. The flags go
the other direction — forcing *re*-work (`irc`, `sdpl`, the `>` list
prefix, `CPLX_FORCE_RELOAD_PACKAGES`) when the evidence is stale, for
example after a mirror served a broken file.

This inversion matches the environment: on a flaky corporate network,
"run it again" must always be the safe move, and destructive freshness
must be the explicit, deliberate exception.

## The failure modes to know

Checkpoints can lie in one direction: a step marked done whose output
was later deleted or corrupted stays done. The cure is never editing
markers by hand but using the reset verbs
([Resume or repeat a step](../how-to/resume-or-repeat-a-step.md)), which
also clear the dependent steps that consumed the bad output.

## 👉 Where to look next

- [steps.md format](../reference/steps-file-format.md) — the exact file
  grammar and API.
