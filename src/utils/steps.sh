#!/bin/bash

STEPS_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "STEPS_DIR='${STEPS_DIR}'"
# shellcheck source=/dev/null
source "${STEPS_DIR}/../echos/echos"

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    if [ $# -eq 0 ]; then
        steps_file="${STEPS_DIR}/steps.test.md"
    fi
fi
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
    if step_parent_should_be_done "${name}"; then
        local parent
        step_parent_of "${name}" "parent"
        step_done "${parent}"
    fi
    return 0
}

step_parent_should_be_done() {
    local name="$1"
    local parent
    step_parent_of "${name}" "parent"
    # if no parent, return false
    if [[ "${parent}" == "" ]]; then return 1; fi
    awk -v "target=parent" -f "${STEPS_DIR}/steps_get_parent.awk" "${steps_file}"
    local should_be_done=0
    while IFS= read -r child; do
        if ! step_is_done "${child}"; then
             should_be_done=1
             break
        fi
    done < <(awk -v target="parent" -f "${STEPS_DIR}/steps_get_parent.awk" "${steps_file}")
    return ${should_be_done}
}

step_parent_of() {
    local current_step_name="$1"
    local parent_var="$2"
    local current_level
    current_level=$(step_level "${current_step_name}")
    if [ "${current_level}" -le 2 ]; then
        # a level 2 item has no parent
        # assign to the variable named after parent_var value to ""
        printf -v "$parent_var" ""
        return 0
    fi
    # Find the parent step: the nearest step above current_step_name with level less than current_level
    parent_step=$(awk -v level="$current_level" -v name="${current_step_name}" -f "${STEPS_DIR}/steps_get_parent.awk" "${steps_file}")
    # shellcheck disable=SC2181
    if [[ $? -gt 0 ]]; then
        fatal "Unable to get parent step for '${current_step_name}' in '${steps_file}'" 108
    fi
    printf -v "$parent_var" "%s" "$parent_step"
    set +x
}

step_level() {
    local name="$1"
    if ! step_exists "${name}"; then
        fatal "Unable to get step level, step '${name}' does not exist in '${steps_file}'" 104
    fi
    local level
    set -o pipefail
    level=$(grep -E "\(#${name}\)" "${steps_file}" | grep -Eo "^#+" | wc -c)
    # shellcheck disable=SC2181
    if [ $? -gt 0 ]; then
        fatal "Unable to get step level, step '${name}' # prefix not found in '${steps_file}'" 106
    fi
    level=$((level - 1))
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

repeat_or_reset_step() {
    local step="$1"
    local reset_needed=false

    # Check if the argument starts with r_
    if [[ "$step" == r_* ]]; then
        reset_needed=true
        step="${step#r_}"
    fi

    # Extract steps from steps.md
    grep_steps=$(grep -oP "\]\((.*?)\)" "${steps_file}" | grep -i "$step")
    if [[ -z "$grep_steps" ]]; then
        fatal "Error: No steps found matching '$step'" 10
    fi
    # Check the number of steps found
    step_count=$(echo "$grep_steps" | wc -l)
    if [[ $step_count -eq 0 ]]; then
        fatal "Error: No steps found matching '$step'" 11
    elif [[ $step_count -gt 1 ]]; then
        fatal "Error: More than one step found matching '$step'" 12
    fi

    # Get the exact step name
    exact_step=$(echo "$grep_steps" | head -n 1)
    # shellcheck disable=SC2001
    exact_step=$(echo "$exact_step" | sed 's/[^a-zA-Z_]//g')

    # Perform repeat or reset
    if ${reset_needed}; then
        task "Must reset step: ${exact_step}"
        if ! reset_step "${exact_step}"; then
            fatal "Unable to reset step '${exact_step}' from '${step}' original name" 222
        fi
    else
        task "Must repeat step: ${exact_step}"
        if ! repeat_step "${exact_step}"; then
            fatal "Unable to repeat step '${exact_step}' from '${step}' original name" 223
        fi
    fi
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

test_steps_done() {
    cp "${steps_file}" "${STEPS_DIR}/steps.test.done.child.tmp.md"
    steps_file="${STEPS_DIR}/steps.test.done.child.tmp.md"
    if ! repeat_step this_second_step_should_be_repeated; then
        fatal "Unable to reset 'this_second_step_should_be_repeated' in '${steps_file}'" $?
    fi

    if step_is_done this_step_should_be_done_again; then
        fatal "'this_step_should_be_done_again' should not be done in '${steps_file}'" $?
    else
        ok "'this_step_should_be_done_again' is not done (child to be repeated) in '${steps_file}'"
    fi
    if ! step_is_done this_first_step_should_not_be_repeated; then
        fatal "'this_first_step_should_not_be_repeated' should done in '${steps_file}'" $?
    else
        ok "'this_first_step_should_not_be_repeated' is still done (not to be repeated) in '${steps_file}'"
    fi
    if step_is_done this_second_step_should_be_repeated; then
        fatal "'this_second_step_should_be_repeated' should not be done in '${steps_file}'" $?
    else
        ok "'this_second_step_should_be_repeated' is not done (to be repeated) in '${steps_file}'"
    fi
    if ! step_is_done this_third_step_should_not_be_repeated; then
        fatal "'this_third_step_should_not_be_repeated' should be done in '${steps_file}'" $?
    else
        ok "'this_third_step_should_not_be_repeated' is done (not to be repeated) in '${steps_file}'"
    fi

    if ! step_done this_second_step_should_be_repeated; then
        fatal "Unable to mark 'this_second_step_should_be_repeated' as done in '${steps_file}'" $?
    fi

    if ! step_is_done this_third_step_should_not_be_repeated; then
        fatal "'this_third_step_should_not_be_repeated' should still be done in '${steps_file}'" $?
    else
        ok "'this_third_step_should_not_be_repeated' is still done (has been repeated) in '${steps_file}'"
    fi
    if ! step_is_done this_step_should_be_done_again; then
        fatal "'this_step_should_be_done_again' should be done in '${steps_file}'" $?
    else
        ok "'this_step_should_be_done_again' is done (all children repeated) in '${steps_file}'"
    fi

}


test_steps_parent_of() {
    local test_parent
    step_parent_of "cascading_repeat_1" "test_parent"
    if [[ "${test_parent}" == "step_to_be_repeated" ]]; then
        ok "Parent of cascading_repeat_1 is step_to_be_repeated"
    else
        fatal "Parent of cascading_repeat_1 should be 'step_to_be_repeated', not '${test_parent}'" 1
    fi
}

# Only run if script is not being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    if [ $# -eq 0 ]; then
        steps_file="${STEPS_DIR}/steps.test.md"
        test_steps_parent_of
        test_steps_done
        exit 0
        test_steps
        test_steps_repeat
        test_steps_repeat_child
        test_steps_reset
    else
        func="$1"
        shift
        if declare -f "$func" > /dev/null; then
            "$func" "$@"
            ret=$?
            if [ ${ret} -ne 0 ]; then
                echo "${ret}"
            fi
        else
            fatal "Error: function '${func}' does not exist." 22
        fi
    fi
fi