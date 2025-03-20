#!/bin/bash
DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"

# Function to display fatal error and exit
fatal() {
  local exit_status=1
  if [[ "$2" != "" ]]; then
    exit_status="$2"
  fi
  echo "FATAL ERROR: $1" >&2
  exit "${exit_status}"
}

# Search for .env in parent directories up to 4 levels up
ENV_PATH=""
CURRENT_DIR="${DIR}"
MAX_LEVELS=4

for ((i=0; i<=MAX_LEVELS; i++)); do
  if [[ -f "${CURRENT_DIR}/.env" ]]; then
    ENV_PATH="${CURRENT_DIR}/.env"
    break
  fi
  # Stop if we're at root directory
  if [[ "${CURRENT_DIR}" == "/" ]]; then
    break
  fi
  CURRENT_DIR="$(dirname "${CURRENT_DIR}")"
done

# Exit if no .env file found
if [[ -z "${ENV_PATH}" ]]; then
  fatal "No .env file found in parent directories (up to $MAX_LEVELS levels)" 2
fi


# Now $ENV_PATH contains the path to the first .env file found

if [[ "$1" != "" ]]; then
  export GIT_LOGIN="$1"
  # shellcheck source=/dev/null
  source "${DIR}/sshgitwrapper.local"
fi

# shellcheck disable=SC1091
source "${ENV_PATH}/.env" || fatal "Error loading .env file: ${ENV_PATH}" 3

if [[ "${SSH_ORIGINAL_COMMAND}" == "" ]]; then
  /bin/bash --init-file <(echo "cd \"${ENV_PATH}\";pwd;source .env")
else
  # eval "args=($SSH_ORIGINAL_COMMAND)"
  IFS=$'\n' read -d '' -r -a args < <(python -c "import shlex, sys; print('\n'.join(shlex.split(sys.argv[1])))" "${SSH_ORIGINAL_COMMAND}")

  # Execute the parsed command using the args array
  "${args[@]}"

  # safer than:
  # eval "${SSH_ORIGINAL_COMMAND}"
fi
