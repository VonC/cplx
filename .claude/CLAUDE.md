# cplx project guidance

This file is the project-level entry point for Claude Code. The root
`CLAUDE.md` is a one-line stub that imports it via `@.claude/CLAUDE.md`, so all
Claude-related configuration lives under `.claude/`, mirroring the `.github/`
convention.

## Shared Claude resources from llm-shared

In addition to anything declared in this repository, also consider the shared
Claude resources kept in the sibling repository `../llm-shared/`:

- `../llm-shared/instructions/` for the canonical skill instructions.
- `../llm-shared/templates/` for the authored document shapes.
- `../llm-shared/rules/` for the command and writing rules.
- `../llm-shared/.claude/skills/`, `agents/` and `commands/` when present.

Treat them as if declared locally. A local entry of the same name takes
precedence.

## Running shell commands for cplx

**Run every command from a CMD session that has called `senv.bat` first, and run
the other commands, `bash.exe` included, inside that same session.** Do not
reach for a bare shell as the default.

The shape that works:

```text
cmd /d /v:on /c "set NO_MORE_SENV_cplx=& senv.bat && <one-executable> <args>"
```

For a shell script the executable is `bash`, invoked from inside that same
`cmd`, never as a separate top-level shell call.

### Why this matters here

The project toolchain exists only on the PATH that `senv.bat` builds: the pinned
Git, the project root, `%HOME%\bin`, and `%PRGS%\shellchecks\current` for the
shellcheck gate. A shell started from the user profile sources none of it.

This is not hypothetical. `shellcheck` is the lint gate this project substitutes
for `check.bat`, and it was reported as "not installed on the authoring host"
across six code-review rounds, and written into the validation record that way,
while the binary was present the whole time and merely absent from one shell's
PATH. An unavailable tool is a claim to verify, not a fact to record.

### Two traps that make a first attempt fail

- `NO_MORE_SENV_cplx` is inherited by child processes, and `senv.bat` returns
  immediately when it is set, so the PATH is never rebuilt. Clear it in the same
  `cmd` process, as shown above. T  he interactive escape hatch is the `fsenv`
  doskey macro.
- Never nest quoted shells. One `cmd`, one executable, plain arguments: no inner
  double quotes, no `$`, no multi-statement script in the chained part.

### When the wrapper is not needed

Reading and searching files needs no project environment. Use the file tools
directly for that, and keep `senv.bat` for toolchain commands: the installer and
setup entry points, the verification harness, `shellcheck`, and `ghog`.

The full contract is `../llm-shared/rules/run_commands.md`, which this section
does not replace.

## Writing rules

Never write an em dash in prose. Use ":", "(...)", "," or ";" instead. This
applies to documents, commit messages and review content alike.
