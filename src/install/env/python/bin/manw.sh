#!/bin/bash
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# shellcheck source=/dev/null
source "${DIR}/echos"
# shellcheck source=/dev/null
source "${DIR}/setenv"

if [[ ! -e "${DIR}/current/share/man/man1/python.1" ]]; then
  ln -nfs "$(readlink "${DIR}/current/share/man/man1/python3.1")" "${DIR}/current/share/man/man1/python.1"
fi

command man "$@"
exit $?
