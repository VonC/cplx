# cplx wiki

<!-- markdownlint-disable MD013 -->

<img src="assets/logo-cplx-transparent.png" alt="cplx logo: two machines and the four cplx themes" width="200">

Each page carries the logo of its main theme: 🌐 the download (Windows
fetches sources and packages from the internet), 🌉 the bridge (the SSH
crossing to the offline Linux box, checkpointed step by step), 🔨 the forge
(the sandboxed compilation), 📦 the shipment (packages, wrappers and
deployment), or 🛠️ cplx as a whole when the page spans them all.

Documentation for [cplx](../README.md), organized on the
[Diátaxis](https://diataxis.fr/) model. The discipline is simple: each page
belongs to exactly one of the four categories below, and never mixes goals:
a tutorial teaches, a how-to guide solves, a reference describes, an
explanation clarifies.

## 🎓 Tutorials

Learning by doing: follow the steps in order, type what is shown, check
what you see. Start here if cplx is new to you.

- 🛠️ [Your first recompiled tool](tutorials/01-your-first-recompiled-tool.md)
- 🔨 [Add a new tool to cplx](tutorials/02-add-a-new-tool.md)
- 🌉 [Target a new Linux server](tutorials/03-target-a-new-linux-server.md)

## 🧭 How-to guides

Recipes for a precise goal, for readers who already know the basics.

- 🌉 [Resume or repeat a step](how-to/resume-or-repeat-a-step.md)
- 🌐 [Add a dependency to a tool](how-to/add-a-dependency-to-a-tool.md)
- 🔨 [Diagnose a failed configure](how-to/diagnose-a-failed-configure.md)
- 🌐 [Update a tool version](how-to/update-a-tool-version.md)
- 🌐 [Add or fix a package mirror](how-to/add-or-fix-a-package-mirror.md)
- 📦 [Promote a build into the live tree](how-to/promote-a-build-into-the-live-tree.md)
- 📦 [Relocate an install to another prefix](how-to/relocate-an-install-to-another-prefix.md)
- 📦 [Manage git credentials with git-pass-helper](how-to/manage-git-credentials-with-git-pass-helper.md)
- 🛠️ [Make a release](how-to/make-a-release.md)

## 📖 Reference

Exact, dry descriptions of commands, formats and conventions.

- 🛠️ [Commands](reference/commands.md)
- 🛠️ [CPLX variables](reference/cplx-variables.md)
- 🌐 [Package list formats](reference/package-list-formats.md)
- 🔨 [Tool contract](reference/tool-contract.md)
- 🛠️ [Directory layout](reference/directory-layout.md)
- 🌉 [steps.md format](reference/steps-file-format.md)
- 📦 [Packaging and relocation tools](reference/relocation-tools.md)
- 🛠️ [Exit codes](reference/exit-codes.md)

## 💡 Explanation

Background and reasoning: why cplx is built the way it is.

- 🛠️ [Why recompile at all](explanation/why-recompile.md)
- 🔨 [What kind of build is this](explanation/what-kind-of-build-is-this.md)
- 🌉 [Two machines, one build](explanation/two-machines-one-build.md)
- 🔨 [The sandbox root](explanation/the-sandbox-root.md)
- 🔨 [Anatomy of a build](explanation/anatomy-of-a-build.md)
- 🌉 [Checkpoints and resume](explanation/checkpoints-and-resume.md)
- 📦 [The build order](explanation/the-build-order.md)
- 📦 [Why binaries remember the build home](explanation/why-binaries-remember-the-build-home.md)
