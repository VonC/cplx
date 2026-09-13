#!/bin/bash
#
# The project's shell lint gate.
#
# This script runs ShellCheck for both the Windows `check.bat` entry point
# used by `ghog check` and the direct Bash command in `.review-validation`.
# It is the repository's mandatory validation floor, so it has to hold for
# every review rather than for one effort.
#
# Scope: every tracked `*.sh` outside `docs/`.
#
# `docs/` is excluded on purpose, and not to make the gate easier. A harness under
# `docs/<version>/` is one effort's evidence, frozen once that effort's review
# closes: `docs/v0.27.0/verify.install-pkg.sh` is retained evidence for a closed
# item, and editing it to satisfy a later gate would alter an artifact somebody
# already reviewed. Those files are not unlinted. Each effort's plan adds its own
# harness to the resolved validation set as a plan addition, which lints it while
# its review is the one that can act on the result.

set -u

cd "$(git rev-parse --show-toplevel)" || {
    echo "lint_shell: not inside a git work tree" >&2
    exit 2
}

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "lint_shell: shellcheck not on PATH; run senv.bat first" >&2
    exit 2
fi

# `git ls-files` rather than `find`, so an untracked scratch script cannot fail
# the gate and a tracked one can never be missed.
mapfile -t scripts < <(git ls-files '*.sh' | grep -v '^docs/')

if [ "${#scripts[@]}" -eq 0 ]; then
    echo "lint_shell: no tracked shell scripts found" >&2
    exit 2
fi

echo "lint_shell: ${#scripts[@]} tracked scripts"
shellcheck "${scripts[@]}" || exit 1
echo "lint_shell: clean"
