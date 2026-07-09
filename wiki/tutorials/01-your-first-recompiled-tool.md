# Your first recompiled tool

<img src="../assets/logo-cplx-transparent.png" alt="" height="90" align="right">

In this tutorial you rebuild one already-registered tool (`pass`) from
source, end to end: the Windows PC downloads everything, the offline Linux
server compiles it, and you come back with a self-contained package. Allow
30 to 60 minutes, mostly download and compile time.

You need: a Windows machine with a
[senv](https://github.com/VonC/setupsenv) session (portable Git, `gum`,
VS Code under `%PRGS%`), this repository cloned with its submodules, and
SSH access to the target Linux server (RHEL/CentOS).

## 1. Declare the SSH crossing

cplx reaches the Linux box through one SSH alias. In `~/.ssh/config`:

```text
Host centos8
    Hostname my-server.example.corp
    User builder
#centos8_cd /home/builder/cplx
```

The comment line is not decorative: `setup.sh` parses `#<alias>_cd` to
learn the remote folder where everything happens (`cplx_path`). Then point
cplx at the alias, in `senv.local.bat`:

```bat
set "SSH_CONFIG_ENTRY=centos8"
```

## 2. Open a cplx session

```cmd
cd /d C:\Users\you\git\cplx
senv
```

The session activates, but ends with `ERROR: CPLX_TOOL not set: use
'st my_tool' to define it before s/sp/i`: cplx always works on one tool
at a time, and every pipeline command needs one. Pick one:

```cmd
st pass
```

`st` (switchtool) matches the name against `tools_to_recompile`, sets
`CPLX_TOOL`, and reloads the session so `senv.local.bat` loads the `pass`
block: `CPLX_VERSION`, `CPLX_URL`, the check markers.

## 3. Set up the remote environment and sources

```cmd
s
```

`setup.bat` runs the checkpointed pipeline of `src\setups\steps.md`:
validates the SSH connection (and records the remote `architecture`, for
example `rhel_9.6_x86_64`), creates the remote folder, streams the
environment scripts over `tar | ssh`, downloads the `pass` source archive
from `CPLX_URL`, and `scp`s it to the remote `tools/pass/sources/`.

Every step that succeeds is marked `(done: ✅)` in `steps.md`: re-running
`s` skips it. That is the resume mechanism, not an accident.

## 4. Install the build dependencies

```cmd
sp
```

`setup.bat packages` reads `src\setups\pkgs\pass\pass_<architecture>.txt`,
resolves each short name against the generated package index, downloads
the RPMs (mirrors, vault, browser-like headers when needed), `scp`s them,
and unpacks them on the server into the tool's private sandbox
`tools/pass/root/`, never into the system. `rpm` and `yum` are not used.

## 5. Compile, package, deploy

```cmd
i
```

`install.bat` copies the install scripts, then runs remotely
`bash ./install pass 1.7.4`: the per-tool phases `setenv`, `configure`,
`clean`, `build`, `install`, `package` run in the sandbox. The full build
log comes back to `src\install\install.log` and opens in VS Code.

## 6. Check the result

On the server:

```bash
ls ~/cplx/tools/pass/*.tar.gz
```

You should see a timestamped, architecture-suffixed package, for example
`pass-1.7.4-20260707.1432.el9.x86_64.tar.gz`, plus wrappers under
`tools/pass/bin/` that run the tool against its own libraries.

## 👉 Next steps

- [Add a new tool to cplx](02-add-a-new-tool.md)
- The phase sequence is dissected in
  [Anatomy of a build](../explanation/anatomy-of-a-build.md).
- The skip-what-is-done behavior is explained in
  [Checkpoints and resume](../explanation/checkpoints-and-resume.md).
