# steps.md format

<img src="../assets/logo-cplx-bridge-transparent.png" alt="" height="90" align="right">

The step runner (`src\utils\steps.sh`) keeps its state in a plain
Markdown file — `src\setups\steps.md` for the live pipeline. This page
describes the format and the operations on it.

## One line per step

```markdown
## Copy the sources {#copy_the_sources} [🔗](#copy_the_sources) (done: ✅)
### Get the version {#get_the_version} [🔗](#get_the_version)
```

| Element | Role |
| --- | --- |
| heading level (`##`, `###`, ...) | position in the tree: deeper heading = child step |
| `{#anchor}` + `[🔗](#anchor)` | the step's identifier, derived from the title (lowercase, spaces → `_`); regenerate with `sfa <file>` after editing a title |
| ` (done: ✅)` suffix | the step completed; its absence means "to run" |

## Semantics

- A script wraps each unit of work in
  `if step_is_done X; then return; fi ... step_done X`; the file *is*
  the checkpoint.
- `step_done` on the last pending child also marks the parent done,
  recursively.
- `repeat_step X` clears X and its children; siblings stay done;
  ancestors are cleared so the branch re-runs.
- `reset_step X` clears X and **every step after it**, regardless of
  level, plus ancestors.
- Step names given on the command line are fuzzy-matched
  (`steps_list_one_step`): a unique fragment suffices, ambiguity is
  fatal.

## Entry points

| Call | Effect |
| --- | --- |
| `s <fragment>` / `s r_<fragment>` | repeat / reset (via `steps.sh repeat_or_reset_step`) |
| `CPLX_REPEAT_STEP` / `CPLX_RESET_STEP` | same, applied at each `setup.sh` run |
| `steps <function> <args>` | call any `steps.sh` function directly |
| `steps.sh` with no argument | self-test against `src\utils\steps.test.md` |

## Tooling around the file

- `.gitattributes` declares `steps.md diff=remove_done_markers`, and
  `senv.bat` configures that textconv (`sed` stripping ` (done: ✅)`), so
  diffs show step *content* changes, not checkpoint noise.
- The cascade semantics (parent un-done when a child repeats, parent
  done when the last child finishes) are specified by the tests
  described in `src\utils\steps.test.md`.
