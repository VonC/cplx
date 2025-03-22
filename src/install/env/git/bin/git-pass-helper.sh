#!/bin/bash

# pass-git-helper.sh for multi-user SSH service account

VERSION="2.0"
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
  if [[ -f "$user_store_dir/.gpg-id" ]]; then
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
  if [[ -f "$user_store_dir/.gpg-id" ]]; then
    echo "Pass password store already initialized for user: $uid"
    return 0
  else
    echo "$uid" > "$user_store_dir/.gpg-id"
  fi

  if check_pass_store "$uid"; then
    echo "Pass password store initialized for user: $uid"
  else
    fatal_error "Failed to initialize password store for $uid."
  fi
}


# Function to get the password from the pass store
get_password_from_store() {
  local uid="$1"
  local host="$2"
  local user_store_dir="$PASSWORD_STORE_BASE/$uid"
  local password_path="$host"
  local username_path="${username}@${host}"
  local gpg_file_path
  local output

  # Check if we have a username@host format file first
  if [[ -f "$user_store_dir/$username_path.gpg" ]]; then
    gpg_file_path="$user_store_dir/$username_path.gpg"
  # Otherwise use just host
  elif [[ -f "$user_store_dir/$password_path.gpg" ]]; then
    gpg_file_path="$user_store_dir/$password_path.gpg"
  else
    return 1
  fi

  # Decrypt the armored file using gpg2
  if output=$("$GPG_COMMAND" --quiet --batch --use-agent \
              --keyring ~/certs/"${GIT_LOGIN}.pub" \
              --secret-keyring ~/certs/"${GIT_LOGIN}.sec" \
              --decrypt "$gpg_file_path" 2>/dev/null); then
    echo "$output"
    return 0
  else
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
  if [[ -n "$username" ]]; then
    password_path="${username}@${host}"
  fi
  local content="$password"
  if [[ -n "$username" ]]; then
    content="$username"$'\n'"$content"
  fi

  export PASSWORD_STORE_DIR="$user_store_dir"

  # Encrypt password with the gpg2 key of uid: put it in an armored text at PASSWORD_STORE_DIR/username@host (or just host if no username provided)

  # Full file path for the encrypted password
  local gpg_file_path="$user_store_dir/$password_path.gpg"

  # Encrypt password with the gpg2 key of uid and save as armored text
  if echo -n "$content" | "$GPG_COMMAND" --keyring ~/certs/"${GIT_LOGIN}.pub" \
     --secret-keyring ~/certs/"${GIT_LOGIN}.sec" \
     --recipient "$uid" \
     --armor \
     --encrypt \
     --yes \
     --output "$gpg_file_path"; then
    chmod 600 "$gpg_file_path"
    return 0
  else
    return 1
  fi
}

# Function to erase the password from the pass store
erase_password_from_store() {
  local uid="$1"
  local host="$2"
  local username="$3"
  local user_store_dir="$PASSWORD_STORE_BASE/$uid"
  local password_path="$host"
  if [[ -n "$username" ]]; then
    password_path="${username}@${host}"
  fi

  rm -f "$user_store_dir/$password_path.gpg" 2>/dev/null
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
    if echo "${fingerprint}:6:" | gpg2 --keyring ~/certs/"${GIT_LOGIN}.pub" --secret-keyring ~/certs/"${GIT_LOGIN}.sec" --import-ownertrust; then
      echo "Successfully set ultimate trust for key '$key_id_or_uid'."
    else
      echo "Error setting ultimate trust for key '$key_id_or_uid'."
      return 1
    fi
  #else
  #  echo "Key '$key_id_or_uid' already has ultimate trust (level 6)."
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

if [[ -z "${username}" ]]; then username="${git_login}"; fi

case "$action" in
  get)
    output=$(get_password_from_store "${git_login}" "$host")

    # Split the output by newlines into an array
    mapfile -t output_lines <<< "$output"

    # If we have multiple lines, first line is username, second is password
    if [[ ${#output_lines[@]} -gt 1 ]]; then
      echo "username=${output_lines[0]}"
      echo "password=${output_lines[1]}"
    # If only one line, assume it's just the password
    else
      echo "password=$output"
    fi
    ;;
  store)
    if [[ -n "$password" ]]; then
      if store_password_in_store "${git_login}" "$host" "$username" "$password"; then
        echo "Stored password for [${username}@]$host in '${PASSWORD_STORE_BASE}/${git_login}' for user ${git_login}."
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
