#!/bin/bash

# pass-git-helper.sh for multi-user SSH service account

VERSION="2.0"
PASS_COMMAND="pass"
GPG_COMMAND="gpg2"
PASSWORD_STORE_BASE="$HOME/.password-store"

# Function to display version information
display_version() {
  echo "git-pass-helper version $VERSION"
  exit 0
}

# Function to exit with an error message
fatal_error() {
  echo "Error: $1" >&2
  exit 1
}

# Function to check if a GPG key with the given UID exists
check_gpg_key() {
  local uid="$1"
  if "$GPG_COMMAND" --keyring ~/certs/"${GIT_LOGIN}.pub" --secret-keyring ~/certs/"${GIT_LOGIN}.sec" --list-keys --with-colons | grep "^uid.*$uid" > /dev/null; then
    return 0 # Key exists
  else
    return 1 # Key does not exist
  fi
}

# Function to generate a GPG key
generate_gpg_key() {
  local uid="$1"
  local real_name
  local passphrase

  echo "Generating2 OpenPGP key for user: $uid"

  # Automatically use uid as real_name
  local real_name="$uid"
  
  # Only prompt for passphrase, redirecting input from /dev/tty
  while true; do
    read -r -s -p "Enter a passphrase for your key (non-empty): " passphrase < /dev/tty
    echo # To move the cursor to the next line after the hidden input
    if [[ -n "$passphrase" ]]; then
      break
    else
      echo "Passphrase cannot be empty."
    fi
  done

  # Write the key generation parameters to the temporary file
  cat <<EOF > k.cmd
%echo Generating OpenPGP key for ${uid}
Key-Type: RSA
Key-Length: 4096
Expire-Date: 0
Name-Real: $real_name
Name-Email: ${uid}@dummy.local
Passphrase: $passphrase
%pubring ${HOME}/certs/$uid.pub
%secring ${HOME}/certs/$uid.sec
%commit
EOF
# Name-Email: ${uid}@dummy.local  # Optional, but GPG might complain without it
# Removing email entry to ensure simple UID
  gpg_output=$("$GPG_COMMAND" --batch --gen-key k.cmd 2>&1)

  if check_gpg_key "$uid"; then
    echo "$uid OpenPGP key generation done."
  else
    echo "GPG key generation failed for $uid. Output from gpg:"
    echo "$gpg_output"
    fatal_error "Failed to generate GPG key for $uid."
  fi

  fatal_error "stop for now" 22
}

# Function to check if the pass store exists
check_pass_store() {
  local user_store_dir="$PASSWORD_STORE_BASE/$1"
  if [[ -d "$user_store_dir" ]]; then
    return 0 # Pass store exists
  else
    return 1 # Pass store does not exist
  fi
}

# Function to initialize the pass store
init_pass_store() {
  local uid="$1"
  local user_store_dir="$PASSWORD_STORE_BASE/$uid"

  mkdir -p "$user_store_dir"
  export PASSWORD_STORE_DIR="$user_store_dir"
  "$PASS_COMMAND" init "$uid"
  unset PASSWORD_STORE_DIR

  if check_pass_store "$uid"; then
    echo "Pass password store initialized for user: $uid"
  else
    fatal_error "Failed to initialize pass password store for $uid."
  fi
}


# Function to get the password from the pass store
get_password_from_store() {
  local uid="$1"
  local host="$2"
  local user_store_dir="$PASSWORD_STORE_BASE/$uid"
  local password_path="$host"

  export PASSWORD_STORE_DIR="$user_store_dir"
  local output

  if output=$("$PASS_COMMAND" show "$password_path" 2>/dev/null); then
    echo "$output"
    unset PASSWORD_STORE_DIR
    return 0
  else
    unset PASSWORD_STORE_DIR
    return 1
  fi
}

# Function to store the password in the pass store
store_password_in_store() {
  local uid="$1"
  local host="$2"
  local username="$3"
  local password="$4"
  local user_store_dir="$PASSWORD_STORE_BASE/$uid"
  local password_path="$host"
  local content="$password"
  if [[ -n "$username" ]]; then
    content="$username"$'\n'"$content"
  fi

  export PASSWORD_STORE_DIR="$user_store_dir"
  if "$PASS_COMMAND" insert -f "$password_path" <<< "$content"; then
    unset PASSWORD_STORE_DIR
    return 0
  else
    unset PASSWORD_STORE_DIR
    return 1
  fi
}

# Function to erase the password from the pass store
erase_password_from_store() {
  local uid="$1"
  local host="$2"
  local user_store_dir="$PASSWORD_STORE_BASE/$uid"
  local password_path="$host"

  export PASSWORD_STORE_DIR="$user_store_dir"
  "$PASS_COMMAND" rm -f "$password_path" 2>/dev/null
  unset PASSWORD_STORE_DIR
}

check_and_set_ultimate_trust() {
  local key_id_or_uid="$1"
  local fingerprint
  local owner_trust

  # Get the fingerprint of the key
  fingerprint=$(gpg2 --keyring ~/certs/"${GIT_LOGIN}.pub" --secret-keyring ~/certs/"${GIT_LOGIN}.sec" --fingerprint "$key_id_or_uid" | grep "^ *Key fingerprint ="| awk -F '=' '{gsub(/ /, "", $2); print $2}')
  if [[ -z "$fingerprint" ]]; then
    echo "Error: Could not retrieve fingerprint for '$key_id_or_uid'."
    return 1
  fi

  # Get the owner trust level
  owner_trust=$(gpg2 --keyring ~/certs/"${GIT_LOGIN}.pub" --secret-keyring ~/certs/"${GIT_LOGIN}.sec" --list-keys --with-colons "$key_id_or_uid" | awk -F: '/^pub:/ {print $9}')

  if [[ "$owner_trust" != "u" ]]; then
    echo "Key '$key_id_or_uid' (fingerprint: '${fingerprint}') does not have ultimate trust (level 6/u vs. '${owner_trust}'). Setting it..."
    echo "${fingerprint}:6:" | gpg2 --keyring ~/certs/"${GIT_LOGIN}.pub" --secret-keyring ~/certs/"${GIT_LOGIN}.sec" --import-ownertrust
    if [[ $? -eq 0 ]]; then
      echo "Successfully set ultimate trust for key '$key_id_or_uid'."
    else
      echo "Error setting ultimate trust for key '$key_id_or_uid'."
      return 1
    fi
  else
    echo "Key '$key_id_or_uid' already has ultimate trust (level 6)."
  fi
  return 0
}

# Main script logic
action="$1"
shift

# Check for version flags
if [[ "$action" == "-v" ]] || [[ "$action" == "--version" ]] || [[ "$action" == "version" ]]; then
  display_version
fi

if [[ -z "${GIT_LOGIN}" ]]; then
  fatal_error "GIT_LOGIN environment variable is not set."
fi
git_login="${GIT_LOGIN}"

if ! check_gpg_key "${git_login}"; then
  generate_gpg_key "${git_login}"
fi

if ! check_and_set_ultimate_trust "${git_login}"; then
  fatal_error "Unable to trust the GPG key for ${git_login}."
fi

if ! check_pass_store "${git_login}"; then
  init_pass_store "${git_login}"
fi

request_data=()
while IFS='=' read -r key value; do
  request_data+=("$key=$value")
done

host=""
username=""
password=""

# Process each key-value pair separately
for pair in "${request_data[@]}"; do
  key="${pair%%=*}"
  value="${pair#*=}"
  case "$key" in
    host) host="$value" ;;
    username) username="$value" ;;
    password) password="$value" ;;
  esac
done

case "$action" in
  get)
    if get_password_from_store "${git_login}" "$host"; then
      # Password found, output it
      output=$(get_password_from_store "${git_login}" "$host")
      IFS=$'\n' read -r stored_username stored_password <<< "$output"
      if [[ -n "$stored_username" ]]; then
        echo "username=$stored_username"
      fi
      if [[ -n "$stored_password" ]]; then
        echo "password=$stored_password"
      fi
    fi
    ;;
  store)
    if [[ -n "$password" ]]; then
      if store_password_in_store "${git_login}" "$host" "$username" "$password"; then
        echo "Stored password for $host in pass for user ${git_login}."
      else
        fatal_error "Failed to store password."
      fi
    fi
    ;;
  erase)
    erase_password_from_store "${git_login}" "$host"
    ;;
  *)
    fatal_error "Unsupported action: $action"
    ;;
esac

exit 0
