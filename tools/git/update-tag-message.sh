#!/bin/bash
# shellcheck source-path=SCRIPTDIR

UPDATE_CHANGELOG_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
# echo "SETUP_DIR='${SETUP_DIR}'"
source "${UPDATE_CHANGELOG_DIR}/../../src/echos/echos"

main() {
  # Assign arguments to variables for clarity
  v_tag_name="${1}"
  file="$2"

  if [[ -z "${v_tag_name}" ]]; then
    git tag -l
    fatal "Tag name is required: vx.y.z" 14
  fi
  tag_before=$(git tag -n "${v_tag_name}")
  if [[ -z "${tag_before}" ]]; then
    info "Tag '${v_tag_name}' not found. Searching for version commit..."
    # Extract version without leading 'v'
    # version="${v_tag_name#v}"
    # Find commit that updated version.txt with this version
    pwd
    version_commit=$(git log --pretty=format:"%H" --grep="set new '${v_tag_name}' from" -- ":/version.txt")

    if [[ -z "${version_commit}" ]]; then
      fatal "Could not find commit updating version to ${v_tag_name}" 15
    fi
    
    info "Found version commit: ${version_commit}"
    # Get date from commit
    c_date_time=$(git show -s --format=%ci "${version_commit}")

    # Get version.txt content at that commit
    git show "${version_commit}:version.txt" > "version.txt.tmp"
    info "Created version.txt.tmp from commit ${version_commit}"
    
    # Set file parameter to version.txt.tmp
    file="version.txt.tmp"
  else
    info "Tag '${v_tag_name}' message before: '${tag_before}'"
    c_date_time=$(git show -s --format=%ci "${v_tag_name}"^{})
  fi
  info "Tag '${v_tag_name}' message before: '${tag_before}'"
  c_date=$(printf "%s" "${c_date_time}" | cut -f1 -d' ' )

  GIT_COMMITTER_DATE="${c_date_time}"
  GIT_AUTHOR_DATE="${c_date_time}"

  # if file is version.txt.tmp and version_commit is not empty, 
  # that means there was no tag 'v_tag_name'.
  # In that case, set an annotated tag (message being just the tag) at version_commit
  # making sure the author date of the created annotated tag is the one from version_commit
  # if file is version.txt.tmp and version_commit is not empty, 
  # that means there was no tag 'v_tag_name'.
  # In that case, set an annotated tag (message being just the tag) at version_commit
  # making sure the author date of the created annotated tag is the one from version_commit
  if [[ "${file}" == "version.txt.tmp" && -n "${version_commit}" ]]; then
    info "Creating new tag '${v_tag_name}' at commit ${version_commit}"

    # Export environment variables to set the tag dates
    export GIT_COMMITTER_DATE="${c_date_time}"
    export GIT_AUTHOR_DATE="${c_date_time}"

    # Create a tag message with just the tag name
    tag_after="${v_tag_name}"

    # Create the annotated tag at the version commit with just the tag name as message
    if ! printf "%s" "${tag_after}" | git tag -a -F - "${v_tag_name}" "${version_commit}"; then
      fatal "Failed to create tag '${v_tag_name}' at commit ${version_commit}" $?
    fi
    
    ok "Created new tag '${v_tag_name}' at commit ${version_commit} with date '${c_date_time}'"
    info "Tag '${v_tag_name}' message: '$(git tag -n1000 "${v_tag_name}")'"
  fi

  if [[ -z "${file}" ]]; then
    warning "Tag file is missing"
    task "Must only update the creation date of the tag to '${c_date_time}', c_date='${c_date}'"
    tag_msg=$(git show -s --format=%N "${v_tag_name}" | tail -n +4 | sed "1s/^.*\? --\? /${c_date} -- /")
    info "Tag message: '${tag_msg}'"
    if ! printf "%s" "${tag_msg}" | git tag -f -a -F - -- "${v_tag_name}" "$(git rev-parse "${v_tag_name}"^{})" ; then
      fatal "Failed to update tag date for '${v_tag_name}' with date '${GIT_AUTHOR_DATE}' / '${GIT_COMMITTER_DATE}" $?
    fi
    ok "Tag date updated for '${v_tag_name}' at date '$(git for-each-ref "refs/tags/${v_tag_name}" --format="Date: %(taggerdate)")'"
    exit 0
  fi

  if [[ ! -e "${file}" ]]; then
    fatal "Tag file '${file}' not found" 10
  fi

  # Remove leading 'v' if present using parameter expansion
  # This removes the first 'v' only if it exists at the start
  tag_pattern="${v_tag_name#v}"

  tag_after=$(awk -v pattern="${tag_pattern}" -f release_reader.awk "${file}" | sed "1s/^.*\? --\? /${c_date} -- /")
  awk_exit_status=$?  # Capture the exit status immediately
  # Check if AWK executed successfully
  if [ "${awk_exit_status}" -ne 0 ]; then
      fatal "Failed to read tag message from '${file}'" "${awk_exit_status}" 20
  fi
  info "Tag '$1' message after: '${tag_after}'"

  if [[ "${tag_before}" == "${tag_after}" ]]; then
    ok "Tag message is the same"
    return 0
  fi

  task "Must update tag message from '${v_tag_name}'"
  if ! printf "%s" "${tag_after}" | git tag -f -a -F - -- "${v_tag_name}" "$(git rev-parse "${v_tag_name}"^{})" ; then
    fatal "Failed to update tag message for '${v_tag_name}' with date '${GIT_COMMITTER_DATE}'" $?
  fi
  ok "Tag message updated for '${v_tag_name}'"
  info "Tag '${v_tag_name}' message after: '$(git tag -n1000 "${v_tag_name}")'"
}

main "$@"
