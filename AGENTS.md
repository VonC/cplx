# Agent instructions

## Project purpose

This repository is primarily concerned with compilation, build tooling, and supporting automation.

Expect a mixture of Windows batch scripts (`.bat` / `.cmd`), shell scripts (`.sh`), compiler invocations, generated build artifacts, and platform-specific tooling.

Before changing a build script, understand which shell and platform it targets. Do not mechanically translate syntax between CMD, PowerShell, Bash, WSL, or another shell.

## Running shell commands

Before the first shell command, read and follow:

```txt
../llm-shared/rules/run_commands.md
```

Apply these rules throughout the task:

* Read and search files directly with the harness file tools or simple commands such as `rg` and `type`.
* Do not invoke an environment wrapper merely to read files.
* Use one shell process per logical command.
* Avoid nested shell quoting.
* Prefer a simple command over a shell-inside-a-shell construction.
* Read targeted output and file ranges rather than dumping large logs or files.
* When a command fails because of quoting or parsing, simplify or rewrite the command. Do not replay the same malformed command.

## Windows batch scripts

Run `.bat` and `.cmd` workflows through CMD.

Prefer:

```cmd
cmd /d /c "<command>"
```

Use:

```cmd
cmd /d /v:on /c "<command>"
```

only when delayed expansion is actually required.

Environment changes made by one tool call do not survive into the next. If a setup batch file must prepare the environment for another executable, invoke both in the same CMD process.

For example:

```cmd
cmd /d /v:on /c "setup.bat && build.bat"
```

Do not run `setup.bat` as a preparation step and assume a later tool call inherits its environment.

Keep the chained command simple. Avoid:

* nested `cmd /c`;
* nested `powershell -Command "..."`;
* `$` expressions inside CMD quoting;
* unnecessary inner double quotes;
* multi-statement PowerShell embedded inside CMD.

CMD does not use `\"` as a quote escape. If a substantial PowerShell script is genuinely required, write it to a temporary `.ps1` file and invoke it with:

```cmd
powershell -ExecutionPolicy Bypass -File <script.ps1>
```

## Shell scripts

Run `.sh` scripts in the shell/environment they are designed for.

Before invoking one, determine whether it expects:

* Git Bash;
* WSL;
* a native Linux environment;
* MSYS2/Cygwin;
* another explicitly configured shell.

Do not assume that a `.sh` script intended for Linux will behave identically under Git Bash or WSL.

Do not rewrite a functioning shell workflow into PowerShell or CMD merely for convenience.

When invoking a shell explicitly, keep the boundary simple. Prefer passing a script file and arguments rather than embedding a long quoted shell program on the command line.

## Compilation and build workflow

Prefer the repository's existing build entry points over reconstructing compiler commands manually.

Before running a broad build:

* inspect the relevant build script or configuration;
* identify the intended target;
* determine whether a narrower compile/check command can validate the current change.

During development:

* prefer the smallest build or compilation step that can establish the next useful result;
* use the full build when required for integration validation or when explicitly requested;
* do not repeatedly perform clean builds when an incremental build is sufficient;
* do not delete caches, generated directories, or compiler state merely to make an unexplained failure disappear.

If a clean rebuild is needed, state why before removing reusable build state.

Preserve the first useful compiler error. Do not bury it under repeated rebuilds.

When compiler output is large, inspect the first actionable error and a bounded amount of surrounding context before running another command.

## Generated files and build artifacts

Distinguish source files from generated output before editing anything.

Do not manually edit a generated file when its source or generator is available.

Before deleting or recreating an output directory, determine whether it contains:

* generated files that can safely be reproduced;
* caches that are intentionally reusable;
* locally produced diagnostics;
* user-created or untracked files.

Do not remove untracked files or broad build trees merely as a troubleshooting shortcut.

## Cross-platform changes

When modifying shared build logic, consider both Windows and Unix-like execution paths.

Do not assume that:

* path separators are interchangeable everywhere;
* executable suffixes are irrelevant;
* environment-variable syntax is portable;
* quoting rules are the same;
* exit-code handling is identical;
* tools installed on Windows are available under WSL or Linux, or vice versa.

Keep platform-specific behavior explicit when that is clearer than clever cross-shell abstractions.

## Execution permissions

This repository's compilation and automation workflows are intended to run unattended.

The project-local Codex configuration is expected to provide the permissions required by those workflows.

* Do not request interactive approval or escalation.
* Do not switch the approval policy to `on-request`.
* Do not repeatedly retry a command that already failed because of a permission restriction.
* If an operation that should be available is unexpectedly blocked, first distinguish a genuine permission problem from a quoting, path, environment, compiler, or script failure.
* If the effective Codex permissions do not match the repository's expected configuration, report the specific mismatch instead of weakening global configuration.
* Ordinary clarification questions to the user remain allowed when useful.

## Long-running builds and quota hygiene

Do not turn long-running compilation or test work into frequent model polling.

* Follow the global Codex quota-hygiene instructions.
* Avoid repeated short polling of long-running compilers, linkers, builds, scripts, or agents.
* For code-mode `wait`, use long waits for long-running work rather than 1-second or 10-second status checks.
* When a build is healthy and still running, wait rather than restarting it or launching a duplicate build.
* If useful progress is written to a log, inspect a bounded tail only when enough time has passed for meaningful new information.
* Do not repeatedly query process listings merely to determine whether an otherwise healthy build is still running.
* For delegated agents, use long `wait_agent` waits and avoid unnecessary status-only `list_agents` calls.
* Do not interrupt or duplicate healthy work merely because a wait interval expired.

Quota hygiene applies to status-only polling; it does not prohibit useful questions to the user.

## Failure handling

Classify a failure before changing anything.

Typical categories include:

* command or quoting error;
* missing executable or PATH issue;
* missing environment setup;
* compiler error;
* linker error;
* dependency-resolution failure;
* platform mismatch;
* permission failure;
* timeout;
* test failure.

Do not treat every nonzero exit code as a sandbox problem.

When a command parsed and started successfully, preserve its diagnostics and investigate the reported failure.

When the shell itself reports errors such as:

```txt
is not recognized as an internal or external command
```

or equivalent quoting/parser errors, fix the command line before changing build configuration or permissions.

Do not repeat an expensive build unchanged unless the previous run was interrupted or there is a concrete reason its result may differ.

## Validation

After a change, validate at the narrowest useful level first.

Where applicable, progress through:

1. syntax or static checks;
2. affected compilation target;
3. affected tests;
4. broader build or integration validation.

A successful narrow build does not substitute for broader validation when the change affects shared build logic.

Conversely, do not run the broadest build after every small edit when a focused target provides the required feedback.
