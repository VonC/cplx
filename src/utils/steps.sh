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

steps_are_not_done() {
  local steps=("$@")
  local done=()

  for step in "${steps[@]}"; do
    if step_is_done "$step"; then
      done+=("$step")
    fi
  done

  if [ ${#done[@]} -eq 0 ]; then
    return 0
  else
    steps_err=$(IFS=, ; echo "${done[*]}")
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
    local initial_step_name="$1"
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
    # set -x
    clear_ancestors_done_status "${initial_step_name}"
    # set +x
}

clear_step_done_status() {
    local step_name="$1"
    if ! step_exists "${step_name}"; then
        fatal "Unable to clear done status, step '${step_name}' does not exist in '${steps_file}'" 110
    fi
    if ! sed -i -E "s/\(#${step_name}\) \(done: ✅\)/\(#${step_name}\)/" "${steps_file}"; then
        return 1
    fi
    return 0
}

clear_ancestors_done_status() {
    local step_name="$1"
    local level
    level=$(step_level "$step_name")
    if [[ -z "$level" || "$level" -lt 3 ]]; then
        return
    fi

    local current_step="$step_name"
    local current_level="$level"

    while [[ "$current_level" -gt 2 ]]; do
        # Find the parent step: the nearest step above current_step with level less than current_level
        parent_step=$(awk -v level="$current_level" -v name="${current_step}" -f "${STEPS_DIR}/steps_get_parent.awk" "${steps_file}")
        # shellcheck disable=SC2181
        if [[ $? -gt 0 ]]; then
            fatal "Unable to get parent step for '${current_step}' in '${steps_file}'" 108
        fi

        if [[ -n "${parent_step}" ]]; then
            # Remove (done: ✅) from parent_step
            if ! clear_step_done_status "${parent_step}"; then
                fatal "Unable to clear done status for parent step '${parent_step}'" 109
            fi
            current_step="${parent_step}"
            current_level=$((current_level - 1))
        else
            break
        fi
    done
}

reset_step() {
    local step_name="$1"
    local initial_step_name="$1"
    if ! step_exists "${step_name}"; then
        fatal "Unable to reset step, step '${step_name}' does not exist in '${steps_file}'" 103
    fi
    if ! sed -i -E "s/\(#${step_name}\).*$/\(#${step_name}\)/" "${steps_file}"; then
        return 1
    fi
    local level
    level=$(step_level "${step_name}")
    ok "Reset step '${step_name}' at level '${level}' in '${steps_file}'"
    # loop as long as next step is not empty
    while :; do
        local n_step
        n_step="$(next_step "${step_name}")"
        [[ -z "${n_step}" ]] && break
        info "Next step for '${step_name}': '${n_step}'"

        local n_level
        n_level="$(step_level "${n_step}")"

        # Reset  the next step to be reset
        sed -i -E "s/\(#${n_step}\).*$/\(#${n_step}\)/" "${steps_file}" || return 1
        ok "Reset step '${n_step}' at level '${n_level}' in '${steps_file}'"
        # move on to the newly reset step
        step_name="${n_step}"
    done
    # set -x
    clear_ancestors_done_status "${initial_step_name}"
    # set +x
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
}

test_steps_repeat() {
    cp "${steps_file}" "${STEPS_DIR}/steps.test.repeat.tmp.md"
    steps_file="${STEPS_DIR}/steps.test.repeat.tmp.md"
    if ! repeat_step step_to_be_repeated; then
        fatal "Unable to repeat step_to_be_repeated in '${steps_file}'" $?
    fi
    if steps_are_not_done step_to_be_repeated cascading_repeat_1 cascading_repeat_2; then
        ok "step_to_be_repeated cascading_repeat_1 cascading_repeat_2 are not done as part of repeat step_to_be_repeated in '${steps_file}'"
    else
        fatal "${steps_err} should not be done as part of repeat step_to_be_repeated in '${steps_file}'" $?
    fi
}

test_steps_repeat_child() {
    cp "${steps_file}" "${STEPS_DIR}/steps.test.repeat.child.tmp.md"
    steps_file="${STEPS_DIR}/steps.test.repeat.child.tmp.md"

    if ! repeat_step this_child_should_be_repeated; then
        fatal "Unable to repeat this_child_should_be_repeated in '${steps_file}'" $?
    fi
    if steps_are_not_done this_child_should_be_repeated this_grandchild_should_be_repeated this_step_should_be_repeated_because_of_repeat_child; then
        ok "this_child_should_be_repeated this_grandchild_should_be_repeated this_step_should_be_repeated_because_of_repeat_child are not done as part of repeat this_child_should_be_repeated in '${steps_file}'"
    else
        fatal "${steps_err} should not be done as part of repeat this_child_should_be_repeated in '${steps_file}'" $?
    fi
}

test_steps_reset() {
    cp "${steps_file}" "${STEPS_DIR}/steps.test.reset.child.tmp.md"
    steps_file="${STEPS_DIR}/steps.test.reset.child.tmp.md"

    if ! reset_step this_child_should_be_reset; then
        fatal "Unable to reset 'this_child_should_be_reset' in '${steps_file}'" $?
    fi
    if steps_are_not_done this_step_should_be_not_done_because_of_a_child_reset this_grandchild_should_be_reset this_other_child_should_be_reset this_step_should_also_be_reset; then
        ok "'this_step_should_be_not_done_because_of_a_child_reset', 'this_grandchild_should_be_reset' 'this_other_child_should_be_reset' and 'this_step_should_also_be_reset' are not done as part of reset 'this_child_should_be_reset' in '${steps_file}'"
    else
        fatal "${steps_err} should be 'not done' as part of reset 'this_child_should_be_reset' in '${steps_file}'" $?
    fi
    if steps_are_done this_child_should_still_be_done_despite_brother_reset; then
        ok "'this_child_should_still_be_done_despite_brother_reset' is still done despite a reset 'this_child_should_be_reset' in '${steps_file}'"
    else
        fatal "${steps_err} should still be done despite a reset of 'this_child_should_be_reset' in '${steps_file}'" $?
    fi
}

# Only run if script is not being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    steps_file="${STEPS_DIR}/steps.test.md"
    test_steps
    test_steps_repeat
    test_steps_repeat_child
    test_steps_reset
fi
