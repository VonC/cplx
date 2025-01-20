# Setup steps

This document list all the necessary steps to setup the compilation project on a remote Linux host.

## Validate the SSH connection [🔗](#validate-the-ssh-connection) (done: ✅)

It makes sure the SSH connection reference a reachable remote Linux host (say '`myHost`'), and that it includes a path (`# cd_[hostname] /path/to/remote/project`) in the `~/.ssh/config`.

## SCP the environment [🔗](#scp-the-environment)

It copies the local "environment" folder (`src/setup/env`) to the remote host, with a bashrc-like file named `.env`, and various settings files like a `.vimrc`.