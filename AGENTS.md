# Agent instructions

## Project purpose

This repository is primarily concerned with compilation, build tooling, and supporting automation.

Expect a mixture of Windows batch scripts (`.bat` / `.cmd`), shell scripts (`.sh`), compiler invocations, generated build artifacts, and platform-specific tooling.

Before changing a build script, identify the shell and platform it targets. Do not mechanically translate syntax between CMD, PowerShell, Bash, WSL, or another shell.

## Running shell commands

Before the first shell command, read and follow:

```txt
../llm-shared/rules/run_commands.md
```

That document defines the general shell contract, including targeted reads, one shell per command, simple quoting, and rewriting malformed commands instead of replaying them.

Project-specific rules:

* Read and search files directly with the harness file tools or simple commands such as `rg` and `type`.

* Do not invoke an environment wrapper merely to read files.

* Run `.bat` and `.cmd` workflows through CMD.

* Prefer `cmd /d /c "<command>"`.

* Add `/v:on` only when delayed expansion is actually required.

* Environment changes made by one tool call do not survive into the next. If a setup batch file prepares the environment for another command, invoke both in the same CMD process, for example:

  ```cmd
  cmd /d /v:on /c "setup.bat && build.bat"
  ```

* Do not run a setup script separately and assume a later tool call inherits its environment.

* If substantial PowerShell is genuinely required, prefer a temporary `.ps1` file invoked with:

  ```cmd
  powershell -ExecutionPolicy Bypass -File <script.ps1>
  ```

  rather than embedding a multi-statement `powershell -Command` inside another quoted shell command.

## Shell scripts

Run `.sh` scripts in the shell/environment they are designed for.

Before invoking one, determine whether it expects:

* Git Bash;
* WSL;
* a native Linux environment;
* MSYS2/Cygwin;
* another explicitly configured shell.

Do not assume that a script intended for Linux behaves identically under Git Bash or WSL.

Do not rewrite a functioning shell workflow into PowerShell or CMD merely for convenience.

When invoking a shell explicitly, prefer passing a script file and arguments rather than embedding a long quoted shell program on the command line.

## Compilation and build workflow

Prefer the repository's existing build entry points over reconstructing compiler commands manually.

Before running a broad build:

* inspect the relevant build script or configuration;
* identify the intended target;
* determine whether a narrower compile or check command can validate the current change.

During development:

* prefer the smallest build or compilation step that establishes the next useful result;
* use the full build when required for integration validation or when explicitly requested;
* do not repeatedly perform clean builds when an incremental build is sufficient;
* do not delete caches, generated directories, or compiler state merely to make an unexplained failure disappear.

If a clean rebuild is genuinely needed, establish why before removing reusable build state.

Preserve the first useful compiler error. When compiler output is large, inspect the first actionable error and a bounded amount of surrounding context before running another build.

Do not repeat an expensive build unchanged unless the previous run was interrupted or there is a concrete reason its result may differ.

## Generated files and build artifacts

Distinguish source files from generated output before editing or deleting anything.

Do not manually edit a generated file when its source or generator is available.

Before deleting or recreating an output directory, determine whether it contains:

* reproducible generated files;
* reusable caches;
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
* tools installed on Windows are also available under WSL or Linux, or vice versa.

Keep platform-specific behavior explicit when that is clearer than cross-shell abstraction.

## Execution permissions

This repository's compilation and automation workflows are intended to run unattended.

Its project-local Codex configuration is expected to provide:

```txt
Full access / never
```

* Do not request interactive approval or escalation.
* Do not change the approval policy to `on-request`.
* If an operation that should be available is unexpectedly blocked, first distinguish a genuine permission problem from a quoting, path, environment, compiler, or script failure.
* If the effective Codex permissions do not match the expected project configuration, report the mismatch rather than weakening the global configuration or repeatedly retrying the blocked command.
* Ordinary clarification questions to the user remain allowed when useful.

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

When the shell itself reports a quoting or parser error such as:

```txt
is not recognized as an internal or external command
```

fix the command line before changing build configuration, permissions, or environment setup.

Follow the global Codex quota-hygiene instructions for long-running builds and processes. In particular, do not busy-poll healthy work or repeatedly restart an operation that is still running.

## Validation

After a change, validate at the narrowest useful level first.

Where applicable, progress through:

1. syntax or static checks;
2. affected compilation target;
3. affected tests;
4. broader build or integration validation.

A successful narrow build does not substitute for broader validation when the change affects shared build logic.

Conversely, do not run the broadest build after every small edit when a focused target provides the required feedback.
