#!/bin/bash
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# shellcheck source=/dev/null
source "${DIR}/echos"
# shellcheck source=/dev/null
source "${DIR}/setenv"

#echo "$-"
#echo "${gitshellenv}"
#if [[ ${gitshellenv} == *i* ]]; then info "interactive";else warning "non interactive";fi

# Make sure .bashrc has alias git='gitshellenv=$- ${DIR}/gitw.sh'
# That will set gitshellenv, used here in this git wrapper script

command man "$@"
exit $?
