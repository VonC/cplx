#!/bin/bash

# Define the function to determine the service based on the current working directory
service_name() {
  local tools
  tools="${1}"
  local cwd
  cwd=$(pwd -P)
  local service

  service=$(printf "%s" "${USER}"|head -c 3)
  service="${service^^}"
  if [[ "${service}" == "VON" ]]; then
    service="CPLX"
    else
    service="${service}-CPLX"
  fi
  # no need for the account for now
  service="CPLX"
  
  # Split the tools string into an array using comma as the delimiter
  IFS=',' read -ra tool_array <<< "${tools}"

  # Loop over each tool in the array
  for tool in "${tool_array[@]}"; do
    # Trim any leading/trailing whitespace
    tool=$(echo "$tool" | xargs)

    # Check if the current working directory matches the tool
    # no glob: if [[ "$cwd" == */$tool/* || "$cwd" == */$tool ]]; then
    if [[ "$cwd" =~ /${tool}(/|$) ]]; then
      # Convert the tool name to uppercase and append it to the service
      echo "${service}-$(echo "$tool" | tr '[:lower:]' '[:upper:]')"
      return
    fi
  done

  # If no tools match, return the default service name
  echo "${service}"
}

export service_name
