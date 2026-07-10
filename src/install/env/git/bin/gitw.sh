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

# shellcheck disable=SC2154
if [[ ${gitshellenv} != *i* ]]; then
  "${DIR}/../current/bin/git" "$@"
  exit $?
fi
#info "interactive Git: checking user"

if [[ "${GIT_LOGIN}" == "" ]]; then
  fatal "Request admin to update '${HOME}/.ssh/authorized_keys and '${DIR}/sshgitwrapper.local' to set GIT_LOGIN" 11
fi
if [[ "${GIT_AUTHOR_NAME}" == "" && "${GIT_AUTHOR_EMAIL}" ]]; then
  fatal "Request admin to update '${DIR}/sshgitwrapper.local' to set missing GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL for user '${GIT_LOGIN}'" 12
fi
if [[ "${GIT_AUTHOR_NAME}" == "" ]]; then
  fatal "Request admin to update '${DIR}/sshgitwrapper.local' to set missing GIT_AUTHOR_NAME for user '${GIT_LOGIN}'/GIT_AUTHOR_EMAIL='${GIT_AUTHOR_EMAIL}" 12
fi
if [[ "${GIT_AUTHOR_EMAIL}" == "" ]]; then
  fatal "Request admin to update '${DIR}/sshgitwrapper.local' to set missing GIT_AUTHOR_EMAIL for user '${GIT_LOGIN}'/GIT_AUTHOR_NAME='${GIT_AUTHOR_NAME}" 12
fi

export GIT_COMMITTER_NAME="${GIT_AUTHOR_NAME}"
export GIT_COMMITTER_EMAIL="${GIT_AUTHOR_EMAIL}"

ok "Valid Git user '${GIT_AUTHOR_NAME}/${GIT_AUTHOR_EMAIL}'"
#warning "GIT_AUTHOR_NAME not set: check user identity from SSH connection"

# The account's real home comes from getent, not from a literal
# /home/<user> path: the relocation text pass of install_pkg.sh
# rewrites any '/home/<x>/' sequence found in deployed text files, and
# a literal here used to swallow the quote that followed it, leaving
# the deployed copy with an unterminated string (seen on the
# 2026-07-10 pre-production deployment).
user_home="$(getent passwd "${USER}" | cut -d: -f6)"
HOME="${user_home:-${HOME}}" "${DIR}/../current/bin/git" "$@"
