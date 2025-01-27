# Setup steps

This document list all the necessary steps to setup the compilation project on a remote Linux host.

## Validate the SSH connection [🔗](#validate_the_ssh_connection) (done: ✅)

It makes sure the SSH connection reference a reachable remote Linux host (say '`myHost`'), and that it includes a path (`# cd_[hostname] /path/to/remote/project`) in the `~/.ssh/config`.

## Copy the environment [🔗](#copy_the_environment) (done: ✅)

It copies the local "environment" folder (`src/setup/env`) to the remote host, with a bashrc-like file named `.env`, and various settings files like a `.vimrc`.

### Create the remote project folder [🔗](#create_the_remote_project_folder) (done: ✅)

It creates the remote project folder, if it does not exist yet.  
That folder (typically `cplx`) is where the various tools will be compiled, each in their own subfolder.

### Transfer env to the remote project folder [🔗](#transfer_env_to_the_remote_project_folder) (done: ✅)

Once the project folder exists, the environment folder is copied to the remote host through `tar` + `ssh`.

## Copy the sources [🔗](#copy_the_sources) (done: ✅)

Check the latests tag, and copies the sources to the remote host.

### Get the latest tag [🔗](#get_the_latest_tag) (done: ✅)

It fetches the latest tag from the tool development repository.  
It the tag differs from what has been recorded in the cplx.properties file, or if the file is missing, it will update the file.

### Transfer the sources to the remote project folder [🔗](#transfer_the_sources_to_the_remote_project_folder) (done: ✅)

Check if the source file exists on the remote server side.  
If not, copy it.
