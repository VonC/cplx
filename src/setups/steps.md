# Setup steps

This document list all the necessary steps to setup the compilation project on a remote Linux host.

## Validate the SSH connection [🔗](#validate-the-ssh-connection) (done: ✅)

It makes sure the SSH connection reference a reachable remote Linux host (say '`myHost`'), and that it includes a path (`# cd_[hostname] /path/to/remote/project`) in the `~/.ssh/config`.

## Copies the environment [🔗](#copy-the-environment)

It copies the local "environment" folder (`src/setup/env`) to the remote host, with a bashrc-like file named `.env`, and various settings files like a `.vimrc`.

### Create the remote project folder [🔗](#create-the-remote-project-folder) (done: ✅)

It creates the remote project folder, if it does not exist yet.  
That folder (typically `cplx`) is where the various tools will be compiled, each in their own subfolder.

### Transfer the environment [🔗](#transfer-env-to-the-remote-project-folder) (done: ✅)

Once the project folder exists, the environment folder is copied to the remote host through `tar` + `ssh`.