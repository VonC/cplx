#!/bin/bash
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"

if [[ "$1" != "" ]]; then
  export GIT_LOGIN="$1"
  # shellcheck source=/dev/null
  source "${DIR}/sshgitwrapper.local"
fi
if [[ "${SSH_ORIGINAL_COMMAND}" == "" ]]; then
  /bin/bash --init-file <(echo 'cd /project/emap1/data/gitcpl;pwd;source .envh')
else
  eval "${SSH_ORIGINAL_COMMAND}"
fi
