#!/bin/bash
# shellcheck source-path=SCRIPTDIR

PROPS_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "PROPS_DIR='${PROPS_DIR}'"
source "${PROPS_DIR}/../echos/echos"

properties_file="${PROPS_DIR}/test.properties"

get_property() {
    local key="$1"
    local value
    value="$(grep -E "^\s*${key}\s*=" "${properties_file}" 2>/dev/null | cut -d= -f2-)"
    value="$(echo "$value" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    if [ -z "$value" ]; then
        eval "${key}=''"
        return 1
    fi
    eval "${key}=\"${value}\""
    return 0
}

get_properties() {
    local keys="$1"
    local file="$2"
    local key
    local missing_keys=()
    for key in $(echo "$keys" | tr ',' ' '); do
        if ! get_property "${key}" "${properties_file}"; then
            missing_keys+=( "${key}" )
        fi
    done

    if [ ${#missing_keys[@]} -gt 0 ]; then
        if [ ${#missing_keys[@]} -eq 1 ]; then
            fatal "Property '${missing_keys[0]}' not found in file '${properties_file}'"
        else
            local joined_missing
            joined_missing="$(IFS=,; echo "${missing_keys[*]}")"
            fatal "Properties '${joined_missing}' not found in file '${properties_file}'" 1
        fi
    fi
}

set_property() {
  local key="$1"
  local newValue="$2"

  # Check if key exists (with spaces around it preserved)
  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "${properties_file}"; then
    # Replace the line, preserving spaces around key, equal sign, and beyond
    sed -i.bak -E "s|^([[:space:]]*)(${key})([[:space:]]*)=([[:space:]]*).*$|\\1\\2\\3=\\4${newValue}|" "${properties_file}"
  else
    # Key not found, add it
    echo "$key=$newValue" >> "${properties_file}"
  fi
}

test_get_property() {
    local key="$1"
    get_property "${key}" "$file"
    echo "key '${key}='${!key}'"
}

test_set_property() {
    local key="$1"
    local value="$2"
    set_property "${key}" "${value}" "$file"
}

# Only run if script is not being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    properties_file="${PROPS_DIR}/test.properties"
    test_get_property key1
    test_get_property key2
    test_get_property key3

    cp "${PROPS_DIR}/test.properties" "${PROPS_DIR}/test2.properties"
    properties_file="${PROPS_DIR}/test2.properties"
    test_set_property key1 value1bis
    test_set_property key2 value2bis
    test_set_property key3 value3bis

    test_get_property key1
    test_get_property key2
    test_get_property key3
fi
