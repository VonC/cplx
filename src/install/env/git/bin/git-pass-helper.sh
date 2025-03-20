#!/bin/bash

# pass-git-helper.sh
# Git credential helper using pass

VERSION="1.0"
CONFIG_FILE="$HOME/.config/pass-git-helper/git-pass-mapping.ini"
PASS_COMMAND="pass"

# Helper function to parse INI file into an associative array
declare -A mapping_config

parse_ini() {
  local file="$1"
  local section=""
  local line

  while IFS= read -r line; do
    line=$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [[ -n "$line" ]]; then
      if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        section="${BASH_REMATCH[1]}"
        mapping_config["$section"]="" # Initialize section
      elif [[ "$line" =~ ^([^=]*)=(.*)$ ]]; then
        local key
        key=$(echo "${BASH_REMATCH[1]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        local value
        value=$(echo "${BASH_REMATCH[2]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        mapping_config["$section:$key"]="$value"
      fi
    fi
  done < "$file"
}

# Helper function to match patterns (basic wildcard support)
match_pattern() {
  local pattern="$1"
  local text="$2"
  case "$text" in
    "$pattern") return 0 ;;
    *)
      if [[ "$pattern" == *"*" ]]; then
        local bash_pattern
        bash_pattern=$(echo "$pattern" | sed 's/\*/./g')
        [[ "$text" =~ ^"$bash_pattern"$ ]]
      fi
      return $?
      ;;
  esac
}

# Function to get the request data
get_request_data() {
  local request=()
  while IFS='=' read -r key value; do
    request+=("$key=$value")
  done
  echo "${request[@]}"
}

# Function to find the mapping target
find_mapping_target() {
  local header="$1"
  local -n config="$2"
  local best_match_target=""
  local best_match_length=-1

  local username host path
  if [[ "$header" =~ ^([^@]+)@([^/]+)(.*)$ ]]; then
    username="${BASH_REMATCH[1]}"
    host="${BASH_REMATCH[2]}"
    path="${BASH_REMATCH[3]}"
  elif [[ "$header" =~ ^([^/]+)(.*)$ ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
  fi

  # Try matching with username@host/path
  for key in "${!config[@]}"; do
    if [[ "$key" =~ ^(.*):target$ ]]; then
      local section="${BASH_REMATCH[1]}"
      if [[ "$section" == "$header" ]]; then
        echo "${config[$key]}"
        return
      fi
    fi
  done

  # Try matching with username@host
  if [[ -n "$username" ]]; then
    local user_host_header="$username@$host"
    for key in "${!config[@]}"; do
      if [[ "$key" =~ ^(.*):target$ ]]; then
        local section="${BASH_REMATCH[1]}"
        if match_pattern "$section" "$user_host_header"; then
          local current_length=${#section}
          if [[ "$current_length" -gt "$best_match_length" ]]; then
            best_match_length="$current_length"
            best_match_target="${config[$key]}"
          fi
        fi
      fi
    done
    if [[ -n "$best_match_target" ]]; then
      echo "$best_match_target"
      return
    fi
  fi

  # Try matching with host/path
  local host_path_header="$host$path"
  for key in "${!config[@]}"; do
    if [[ "$key" =~ ^(.*):target$ ]]; then
      local section="${BASH_REMATCH[1]}"
      if match_pattern "$section" "$host_path_header"; then
        local current_length=${#section}
        if [[ "$current_length" -gt "$best_match_length" ]]; then
          best_match_length="$current_length"
          best_match_target="${config[$key]}"
        fi
      fi
    fi
  done
  if [[ -n "$best_match_target" ]]; then
    echo "$best_match_target"
    return
  fi

  # Try matching with just host
  for key in "${!config[@]}"; do
    if [[ "$key" =~ ^(.*):target$ ]]; then
      local section="${BASH_REMATCH[1]}"
      if match_pattern "$section" "$host"; then
        local current_length=${#section}
        if [[ "$current_length" -gt "$best_match_length" ]]; then
          best_match_length="$current_length"
          best_match_target="${config[$key]}"
        fi
      fi
    fi
  done

  echo "$best_match_target"
}

# Function for the 'get' action
handle_get() {
  local target="$1"
  local request_str="$2"
  local username password

  if "$PASS_COMMAND" show "$target" 2>/dev/null; then
    IFS=$'\n' read -r username password <<< "$output"
    if [[ -n "$username" ]]; then
      echo "username=$username"
    fi
    if [[ -n "$password" ]]; then
      echo "password=$password"
    fi
  else
    echo "Error: $target not found in password store." >&2
    exit 1
  fi
}

# Function for the 'store' action
handle_store() {
  local target="$1"
  local request_str="$2"
  local username password protocol host

  while IFS='=' read -r key value <<< "$request_str"; do
    case "$key" in
      username) username="$value" ;;
      password) password="$value" ;;
      protocol) protocol="$value" ;;
      host) host="$value" ;;
    esac
  done

  local content="$password"
  if [[ -n "$username" ]]; then
    content="$username"$'\n'"$content"
  fi

  if "$PASS_COMMAND" insert -f "$target" <<< "$content"; then
    # Success
    :
  else
    echo "Error storing password in pass for $target" >&2
    exit 1
  fi
}

# Function for the 'erase' action
handle_erase() {
  local target="$1"
  if "$PASS_COMMAND" rm -f "$target" 2>/dev/null; then
    # Success
    :
  else
    echo "Error removing $target from password store (entry might not exist)" >&2
    exit 1
  fi
}

# Main script logic
action="$1"
shift

request_str=$(get_request_data)

parse_ini "$CONFIG_FILE"

header=""
while IFS='=' read -r key value <<< "$request_str"; do
  case "$key" in
    username)
      if [[ -n "$header" ]]; then
        header="$value@${header#*@}"
      else
        header="$value@"
      fi
      ;;
    host)
      if [[ "$header" == *"@"* ]]; then
        header="${header}""$value"
      else
        header="$value"
      fi
      ;;
    path)
      header="$header""$value"
      ;;
  esac
done

target=$(find_mapping_target "$header" mapping_config)

if [[ -z "$target" ]]; then
  echo "Error: No mapping found for header: $header" >&2
  exit 1
fi

case "$action" in
  get)
    handle_get "$target" "$request_str"
    ;;
  store)
    handle_store "$target" "$request_str"
    ;;
  erase)
    handle_erase "$target"
    ;;
  *)
    echo "Error: Unsupported action: $action" >&2
    exit 1
    ;;
esac

exit 0