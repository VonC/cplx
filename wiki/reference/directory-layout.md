# Directory layout

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

The two trees: the repository on Windows, and the working tree it creates
on the Linux server under `cplx_path` (the folder named by the
`#<alias>_cd` comment in `~/.ssh/config`, typically `~/cplx`).

## Windows — the repository

```text
cplx\
├── senv.bat              session entry point (aliases, PATH, guards)
├── senv.local.bat        machine-local config (not committed)
├── all.bat / build.bat / run.bat   dev_workflow build chain
├── version.txt, CHANGELOG.md, changelog-header.md, .changelog.fixes
├── src\
│   ├── setups\           pipeline A (env+sources) and B (packages)
│   │   ├── setup.bat, setup.sh, setup_packages.sh, steps.md
│   │   ├── setup.properties (+ .tpl)
│   │   ├── sources\      downloaded source archives
│   │   ├── pkgs\         package index, per-tool lists, downloaded RPMs
│   │   ├── doc\          package_list_urls.md (mirror notebook)
│   │   └── env\          everything shipped to the server
│   │       ├── .env, cplx.properties (+ .tpl)
│   │       ├── bin\      packages_management.sh, rsync.sh, compare_file.sh
│   │       └── tools\    remote bootstrap `setup`
│   ├── install\          the compile side
│   │   ├── install.bat, doc.md (troubleshooting knowledge base)
│   │   └── env\          shipped to the server as tools/
│   │       ├── install, install_functions.sh
│   │       ├── tool_install_functions.tpl.sh
│   │       └── <tool>\   <tool>_install_functions.sh, bin\ wrappers
│   ├── utils\            steps.sh, properties.sh, steps_format_anchors.sh
│   └── echos\            bash colored output
├── tools\                add_tool.bat, switchtool.bat, init.bat, git\,
│   └── dev_workflow\     version/changelog submodule (batcolors inside)
└── t\                    GCC installation manual (reference copy)
```

## Linux — the working tree (`cplx_path`, e.g. `~/cplx`)

```text
~/cplx/
├── .env                  remote bashrc: aliases, PATH, HOME redirection
├── bin\                  utils + packages_management.sh
├── echos\                colored output
└── tools\
    ├── install, install_functions.sh, cplx.properties
    ├── pkgs\             downloaded RPMs + packages built by libraries
    ├── tool -> <tool>    symlink to the tool being built
    └── <tool>\
        ├── sources\      archives; <version>\ extracted; current -> real dir
        ├── <tool>-<version>\   the install prefix
        ├── current -> <tool>-<version>
        ├── root\         the sandbox: unpacked RPM dependencies
        ├── pkgs\         .installed / .installed.mirrored / .list flags
        ├── bin\          runtime wrappers + setenv (binaries only)
        ├── logs\         one log per run; log -> latest
        └── <tool>-<ver>-<stamp>.<arch>.tar.gz   the product
```

## Linux — the live tree (`~/tools`)

Deployment target of `rsync.sh`: same `<tool>/current` + `bin/` wrapper
shape, but this is what user sessions put on their PATH. Only the
`current` version of each tool survives promotion
([Promote a build](../how-to/promote-a-build-into-the-live-tree.md)).
