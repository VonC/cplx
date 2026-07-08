# Add a new tool to cplx

<img src="../assets/logo-cplx-forge-transparent.png" alt="" height="90" align="right">

In this tutorial you register a brand-new tool into the build system with
the `add_tool` wizard, then make it compile. At the end you understand the
contract every tool honors: three shell functions and a handful of
`CPLX_*` markers.

You need a working cplx session ([tutorial 01](01-your-first-recompiled-tool.md))
and the upstream download URL of the tool you want, for example
`https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz`.

## 1. Run the wizard

```cmd
at hello
```

`tools\add_tool.bat` (gum-driven) asks in turn:

- **Binary or Library**: a binary ships wrappers and is not deployed to
  the shared `tools/pkgs`; a library is (`CPLX_BIN`).
- **Download URL**: paste it with the real version; the wizard replaces
  the version with the `[version]` placeholder by itself.
- **Version**, **archive extension** (auto-detected from the URL), and
  **`CPLX_CONFIG_DONE`** (keep `default` for a standard autotools build).

## 2. See what it wired for you

One run touches all the registration points, in lockstep:

- `hello` appended to `services` and `tools_to_recompile` in
  `setup.properties`, `setup.tpl.properties`, `env\cplx.properties` and
  their `.tpl` twins,
- a `hello` block in `senv.local.bat` and `tools\senv.local.tpl`,
- `src\install\env\hello\hello_install_functions.sh` copied from the
  template `tool_install_functions.tpl.sh`,
- `src\setups\pkgs\hello\hello_<arch>.txt` dependency lists seeded from
  `minimal_<arch>.txt` (glibc headers, cpp: the bare compile set).

## 3. Fill the two check markers

Edit the `hello` block in `senv.local.bat`: `CPLX_CHECK_SRC` names a file
that only exists once `make` succeeded (for `hello`: `src/hello`), and
`CPLX_CHECK_PREFIX` its installed counterpart (`bin/hello`). cplx compares
their timestamps to decide what can be skipped on the next run.

## 4. Build it

```cmd
st hello
s
sp
i
```

The template's `configure()` runs `./configure --prefix=${tool_prefix}`,
`build()` runs `make`, `clean()` runs `make clean`. For a plain autotools
tool this is enough; nothing else to write.

## 5. When the template is not enough

Open `src\install\env\hello\hello_install_functions.sh` and override:

- `configure()` to pass flags (see `curl`: `--with-openssl=${root}/usr`),
- `build()` / `clean()` for non-make systems (see `pass`, which has no
  configure at all and fakes `config.log`),
- add a `hello_setenv()` function when the environment itself must change
  (see `glibc`, `gcc`, `make4`).

Missing build dependencies show up as configure or link errors: add their
short names to `src\setups\pkgs\hello\hello_<arch>.txt` and re-run `sp`
(see [Add a dependency to a tool](../how-to/add-a-dependency-to-a-tool.md)).

## ✅ Check

`i` finishes with a `hello-2.12.1-<timestamp>.<arch>.tar.gz` package in
the remote `tools/hello/`, and `git status` shows the new tool registered
in the properties, template and package-list files.

## 👉 Next steps

- The exact function-and-marker contract:
  [Tool contract](../reference/tool-contract.md).
- What the sandbox `root/` is for:
  [The sandbox root](../explanation/the-sandbox-root.md).
