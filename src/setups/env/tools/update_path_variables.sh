#!/bin/bash
# shellcheck disable=SC2139

# update_path_variable: Safely modify PATH-like environment variables
#
# PURPOSE:
#   Prevents duplicate entries in environment variables like PATH, LD_LIBRARY_PATH, 
#   MANPATH, etc. This ensures consistent behavior and avoids bloating path variables 
#   with redundant entries which could lead to:
#   - Slower path resolution
#   - Harder debugging of environment issues
#   - Unexpected behavior when the same path appears multiple times
#
# PARAMETERS:
#   $1 (var_name)       - The name of the environment variable to modify
#   $2 (folder_path)    - The directory path to add to the variable
#   $3 (append_to_path) - If non-empty, append to end; otherwise prepend to beginning
#
# USAGE EXAMPLES:
#   update_path_variable "PATH" "/opt/custom/bin" ""      # Prepend to PATH
#   update_path_variable "LD_LIBRARY_PATH" "/usr/local/lib" "append"  # Append to LD_LIBRARY_PATH
#
update_path_variable() {
    local var_name=$1
    local folder_path=$2
    local append_to_path=$3

    # Get the current value of the variable
    local var_value
    var_value=$(eval echo \$"${var_name}")

    # Check if the folder path is already in the variable value
    if [[ ":$var_value:" != *":$folder_path:"* ]]; then
        if [[ -z "${var_value}" ]]; then
            # If the variable is empty, set it directly
            var_value="${folder_path}"
        # Update the variable value
        elif [[ -n "${append_to_path}" ]]; then
            # Append the folder path to the end
            var_value="${var_value}:${folder_path}"
        else
            # Prepend the folder path to the beginning
            var_value="${folder_path}:${var_value}"
        fi
        eval export "${var_name}"="${var_value}"
    fi
}
