#!/bin/bash

STEPS_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "STEPS_DIR='${STEPS_DIR}'"
# shellcheck source=/dev/null
source "${STEPS_DIR}/../echos/echos"

steps_file="${STEPS_DIR}/steps.test.md"
steps_err=""

step_exists() {
    local name="$1"
    if [[ ! -e "${steps_file}" ]]; then
        return 1
    fi
    if grep -Eq "\(#${name}\)" "${steps_file}"; then
        return 0
    fi
    return 1
}

steps_are_done() {
  local steps=("$@")
  local not_done=()

  for step in "${steps[@]}"; do
    if ! step_is_done "$step"; then
      not_done+=("$step")
    fi
  done

  if [ ${#not_done[@]} -eq 0 ]; then
    return 0
  else
    steps_err=$(IFS=, ; echo "${not_done[*]}")
    return 1
  fi
}

step_is_done() {
    local name="$1"
    if [[ ! -e "${steps_file}" ]]; then
        return 2
    fi
    if ! step_exists "${name}"; then
        fatal "Unable to check if step is done, step '${name}' does not exist in '${steps_file}'" 102
    fi
    # (#step-is-done) (done: ✅)
    if grep -Eq "\(#${name}\)\s+\(done: ✅\)" "${steps_file}"; then
        return 0
    fi
    return 1
}

step_done() {
    local name="$1"
    if [[ ! -e "${steps_file}" ]]; then
        touch "${steps_file}"
    fi
    if ! step_exists "${name}"; then
        fatal "Unable to mark step as done, step '${name}' does not exist in '${steps_file}'" 101
    fi
    # Check if the step is already marked as done
    if step_is_done "${name}"; then
        return 0
    fi
    # Add the done mark to the line with #the_step_name
    if ! sed -i -E "s/\(#${name}\)/\(#${name}\) (done: ✅)/" "${steps_file}"; then
        return 1
    fi
    return 0
}

step_level() {
    local name="$1"
    if ! step_exists "${name}"; then
        fatal "Unable to get step level, step '${name}' does not exist in '${steps_file}'" 104
    fi
    local level
    set -o pipefail
    level=$(grep -E "\(#${name}\)" "${steps_file}" | grep -Eo "^#+" | wc -c)
    level=$((level - 1))
    # shellcheck disable=SC2181
    if [ $? -gt 0 ]; then
        fatal "Unable to get step level, step '${name}' # prefix not found in '${steps_file}'" 106
    fi
    if [ "${level}" -eq 0 ]; then
        fatal "Unable to get step level, step '${name}' does not have a level in '${steps_file}'" 105
    fi
    echo "${level}"
}

repeat_step() {
    local step_name="$1"
    if ! step_exists "${step_name}"; then
        fatal "Unable to repeat step, step '${step_name}' does not exist in '${steps_file}'" 103
    fi
    if ! sed -i -E "s/\(#${step_name}\).*$/\(#${step_name}\)/" "${steps_file}"; then
        return 1
    fi
    local level
    level=$(step_level "${step_name}")
    ok "Repeating step '${step_name}' at level '${level}' in '${steps_file}'"
    # loop as long as next step is not empty, and is not the same level or higher
    while :; do
        local n_step
        n_step="$(next_step "${step_name}")"
        [[ -z "${n_step}" ]] && break
        info "Next step for '${step_name}': '${n_step}'"

        local n_level
        n_level="$(step_level "${n_step}")"
        (( n_level <= level )) && break

        # Mark the next step to be repeated
        sed -i -E "s/\(#${n_step}\).*$/\(#${n_step}\)/" "${steps_file}" || return 1
        ok "Repeating step '${n_step}' at level '${n_level}' in '${steps_file}'"
        # move on to the newly repeated step
        step_name="${n_step}"
    done
}

next_step() {
    local step_name="$1"
    if ! step_exists "${step_name}"; then
        fatal "Unable to get next step, step '${step_name}' does not exist in '${steps_file}'" 107
    fi
    local next_step_name
    next_step_name="$(awk -v s="(#${step_name})" 'index($0, s) { found=1; next } found == 1 && $0 ~ /^#/ { if (match($0, /\(#([^)]*)\)/, arr)) { print arr[1] }; exit }' "${steps_file}")"
    if [[ -z "${next_step_name}" ]]; then
        echo ""
        return 1
    fi
    echo "${next_step_name}"
}

test_steps() {
    steps_file="${STEPS_DIR}/steps.test.md"
    if step_is_done this_step_is_done; then
        ok "this_step_is_done is already done in '${steps_file}'"
    else
        fatal "this_step_is_done is not done, and should be done in '${steps_file}'" $?
    fi
    if ! step_is_done this_step_is_not_done; then
        ok "this_step_is_not_done is not already done in '${steps_file}'"
    else
        fatal "this_step_is_not_done is done, and should not be done in '${steps_file}'" $?
    fi
    if step_exists "unknown_step"; then
        fatal "unknown_step should not exist in '${steps_file}'" $?
    else
        ok "unknown_step does not exist in '${steps_file}'"
    fi
    cp "${steps_file}" "${STEPS_DIR}/steps.test.repeat.tmp.md"
    steps_file="${STEPS_DIR}/steps.test.repeat.tmp.md"
    if ! repeat_step step_to_be_repeated; then
        fatal "Unable to repeat step_to_be_repeated in '${steps_file}'" $?
    fi
    if ! steps_are_done step_to_be_repeated cascading_repeat_1 cascading_repeat_2; then
        ok "step_to_be_repeated cascading_repeat_1 cascading_repeat_2 are not done as part of repeat step_to_be_repeated in '${steps_file}'"
    else
        fatal "${steps_err} should not be done as part of repeat step_to_be_repeated in '${steps_file}'" $?
    fi
}

# Only run if script is not being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    test_steps
fi
