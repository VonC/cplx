#!/bin/bash
VERSION="2.3" # Updated version

# Function to display version information
display_version() {
  echo "git-pass-helper version $VERSION"
}

# Find the script's own directory
DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# --------------------------- Usage Function ---------------------------------
# Displays help information for the script.
usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

A git-credential helper and GPG key manager for secure, automated credential storage.

Commands:
  store                   Reads credentials (e.g., "host=...") from stdin, ensures a
                          GPG key exists for the current user, and stores the
                          credentials in an encrypted file.

  get                     Reads key-value pairs (e.g. "host=...") from stdin
                          and retrieves/decrypts the matching credentials.

  erase                   Reads key-value pairs (e.g. "host=...") from stdin
                          and deletes the matching encrypted credentials.

  list                    Lists all currently stored encrypted credential files.

  init-gpg                Initializes and verifies the GPG environment, sanitizes
                          the configuration, and lists existing keys.

  help, -h, --help        Displays this help message.

  version, -v, --version  Display the git-pass-helper version.

Environment Variables:
  GPG_KEY_PASSPHRASE    If set, this passphrase is used to automatically generate
                        a new GPG key if one is not found. If not set, the
                        script will prompt interactively.

  GIT_LOGIN, GPG_UID,   Used in order of precedence to determine the user ID for
  GIT_AUTHOR_EMAIL, USER  key management and credential storage/retrieval.

EOF
}

# --------------------------- Fatal Error Function ---------------------------------
# Displays a fatal_error error and exits.
fatal_error() {
  local exit_status=1
  [[ "${2:-}" != "" ]] && exit_status="$2"
  echo "FATAL ERROR: $1" >&2
  exit "${exit_status}"
}

# ------------------------ .env File Lookup --------------------------
# Search for .env in parent directories up to 4 levels
ENV_PATH=""
CURRENT_DIR="${DIR}"
MAX_LEVELS=4
for ((i = 0; i <= MAX_LEVELS; i++)); do
  if [[ -f "${CURRENT_DIR}/.env" ]]; then
    ENV_PATH="${CURRENT_DIR}"
    break
  fi
  [[ "${CURRENT_DIR}" == "/" ]] && break
  CURRENT_DIR="$(dirname "${CURRENT_DIR}")"
done
[[ -z "${ENV_PATH}" ]] && fatal_error "No .env file found in parent directories (up to $MAX_LEVELS levels)" 2

dot_env="${ENV_PATH}/.env"
if [[ -e "${ENV_PATH}/.env_" ]]; then dot_env="${ENV_PATH}/.env_"; fi

# shellcheck disable=SC1090
source "${dot_env}" || fatal_error "Error loading .env file: '${dot_env}'" 3

# ------------------------- GPG Initialization ---------------------------
# Centralized GnuPG home (defaults to your tools/certs)
export GNUPGHOME="${GNUPGHOME:-/home/upipdfs01/tools/certs}"
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

# Pick gpg command (prefer gpg2 if present)
GPG_COMMAND="${GPG_COMMAND:-$(command -v gpg2 || command -v gpg)}"

# Sanitize gpg.conf from legacy options that cause warnings
if [[ -f "$GNUPGHOME/gpg.conf" ]]; then
  sed -i.bak -E '/^[[:space:]]*(secret-keyring|keyring)[[:space:]]/d' "$GNUPGHOME/gpg.conf" || true
fi

# Ensure gpg-agent allows passphrases from scripts (harmless if already the default)
printf '%s\n' 'allow-loopback-pinentry' >>"$GNUPGHOME/gpg-agent.conf" 2>/dev/null || true
gpgconf --reload gpg-agent >/dev/null 2>&1 || true

if [[ -z "${gitshellenv}" ]]; then gitshellenv=$-; fi

# ------------------------- GPG Helper Functions -----------------------------
# Ensures a key for a given User ID exists, creating it if it doesn't.
gpg_ensure_key() {
  local uid="$1"
  # Check if a secret key for the UID already exists
  if ! "$GPG_COMMAND" --batch --list-secret-keys "$uid" >/dev/null 2>&1; then
    if [[ -n "${GPG_KEY_PASSPHRASE:-}" ]]; then
      echo "No GPG key found for '$uid'. Generating a new one using the provided passphrase..."
      "$GPG_COMMAND" --batch --yes --pinentry-mode loopback \
        --passphrase "$GPG_KEY_PASSPHRASE" \
        --quick-generate-key "$uid" rsa4096 encrypt,sign,auth 1y
    elif [[ ${gitshellenv} == *i* ]]; then
      echo "No GPG key found for '$uid'."
      read -rp "Choose an option: [1] Generate without a passphrase [2] Enter a passphrase now: " choice </dev/tty
      case "$choice" in
      1)
        read -rp "Are you sure you want to create a key with NO passphrase? (y/N) " confirm </dev/tty
        if [[ "${confirm,,}" != "y" ]]; then
          fatal_error "Aborted by user."
        fi
        echo "Generating key without a passphrase."
        "$GPG_COMMAND" --batch --yes --quick-generate-key "$uid" rsa4096 encrypt,sign,auth 1y
        ;;
      2)
        read -rs -p "Enter new passphrase: " pass1 </dev/tty
        echo
        read -rs -p "Enter passphrase again: " pass2 </dev/tty
        echo
        if [[ -z "$pass1" || "$pass1" != "$pass2" ]]; then
          fatal_error "Passphrases do not match or are empty. Aborting."
        fi
        "$GPG_COMMAND" --batch --yes --pinentry-mode loopback \
          --passphrase "$pass1" \
          --quick-generate-key "$uid" rsa4096 encrypt,sign,auth 1y
        ;;
      *)
        fatal_error "Invalid choice. Aborting."
        ;;
      esac
    else
      fatal_error "GPG key for '$uid' is missing. Run interactively to create one or set GPG_KEY_PASSPHRASE."
    fi
  fi
}

# Encrypts content from stdin to a file for a given UID
gpg_encrypt_to_file() {
  local uid="$1" out="$2"
  mkdir -p "$(dirname "$out")"
  "$GPG_COMMAND" --batch --yes --armor --recipient "$uid" --encrypt --output "$out"
}

# Decrypts a file to standard output
gpg_decrypt_file() {
  local in="$1"
  "$GPG_COMMAND" --quiet --batch --decrypt "$in"
}

# ---------------------- Main Logic: Subcommands ---------------------
# Implement git-credential helper behavior with subcommands
case "${1:-}" in
"" | "-h" | "--help" | "help")
  usage
  exit 0
  ;;

"-v" | "--version" | "version")
  display_version
  exit 0
  ;;

init-gpg)
  echo "GPG environment successfully initialized."
  echo "GNUPGHOME is: $GNUPGHOME"
  "$GPG_COMMAND" --version
  echo "--- Existing Keys ---"
  "$GPG_COMMAND" --list-keys || true
  exit 0
  ;;

store)
  uid="${GIT_LOGIN:-${GPG_UID:-${GIT_AUTHOR_EMAIL:-${USER}}}}"
  gpg_ensure_key "$uid"

  content="$(cat)"
  host="$(printf "%s" "$content" | awk -F= '/^host=/{print $2; exit}')"
  [[ -z "$host" ]] && fatal_error "No 'host=' found in input."

  out="$ENV_PATH/.secure/git-pass/${uid}/${host}.asc"
  printf "%s" "$content" | gpg_encrypt_to_file "$uid" "$out"
  echo "Stored encrypted credentials at: $out"
  exit 0
  ;;

get)
  ### UPDATED: Reads from stdin like 'store' ###
  uid="${GIT_LOGIN:-${GPG_UID:-${GIT_AUTHOR_EMAIL:-${USER}}}}"

  # Read host from stdin
  host="$(awk -F= '/^host=/{print $2; exit}')"
  [[ -z "$host" ]] && fatal_error "Could not find 'host=' in standard input."

  in="$ENV_PATH/.secure/git-pass/${uid}/${host}.asc"
  [[ ! -f "$in" ]] && exit 0 # Fail silently as per git-credential helper spec
  gpg_decrypt_file "$in"
  exit 0
  ;;

erase)
  ### UPDATED: Reads from stdin like 'store' ###
  uid="${GIT_LOGIN:-${GPG_UID:-${GIT_AUTHOR_EMAIL:-${USER}}}}"

  # Read host from stdin
  host="$(awk -F= '/^host=/{print $2; exit}')"
  [[ -z "$host" ]] && fatal_error "Could not find 'host=' in standard input."

  in="$ENV_PATH/.secure/git-pass/${uid}/${host}.asc"
  if [[ -f "$in" ]]; then
    rm "$in"
    echo "Erased credentials for host '$host' for user '$uid'."
  fi
  exit 0
  ;;

list)
  find "$ENV_PATH/.secure/git-pass" -type f -name '*.asc' 2>/dev/null || true
  exit 0
  ;;

*)
  fatal_error "Unknown command: '$1'. Use -h or --help to see available commands."
  ;;
esac
