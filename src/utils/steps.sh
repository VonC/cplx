#!/bin/bash

STEPS_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "STEPS_DIR='${STEPS_DIR}'"
# shellcheck source=/dev/null
source "${STEPS_DIR}/../echos/echos"

steps_file="${STEPS_DIR}/steps.test.md"

step_is_done() {
    local name="$1"
    if [[ ! -e "${steps_file}" ]]; then
        return 2
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
    # Check if the step is already marked as done
    if step_is_done "${name}"; then
        return 0
    fi
    # Add the done mark to the line with #the_step_name
    if ! sed -i.bak -E "s/\(#${name}\)/\(#${name}\) (done: ✅)/" "${steps_file}"; then
        return 1
    fi
    return 0
}

test_steps() {
    steps_file="${STEPS_DIR}/steps.test.md"
    if step_is_done step-is-done; then
        ok "step-is-done is already done"
    else
        fatal "step-is-done is not done, and should be done" $?
    fi
}

# Only run if script is not being sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    test_steps
fi
