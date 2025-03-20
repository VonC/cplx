#!/bin/bash

case "${GIT_LOGIN}" in
'a_username')
  export GIT_AUTHOR_NAME="FirstName LastName"
  export GIT_AUTHOR_EMAIL="firstname.lastname@company.com"
;;
esac