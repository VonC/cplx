#!/bin/bash
# shellcheck source-path=SCRIPTDIR

UPDATE_CHANGELOG_DIR="$( cd "$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd )"
PROJECT_DIR="$( dirname "${UPDATE_CHANGELOG_DIR}" )"
# echo "SETUP_DIR='${SETUP_DIR}'"
source "${UPDATE_CHANGELOG_DIR}/../src/echos/echos"

main() {
  gcliff=( "$(cygpath -u "${PRGS}/git-cliffs/current/git-cliff.exe")" -c "${PROJECT_DIR}/tools/cliff.toml" -w "${PROJECT_DIR}" -s footer -o "${PROJECT_DIR}/CHANGELOG.tmp.md" )
  info "gcliff='${gcliff[*]}'"
  "${gcliff[@]}" -V

  if [[ ! -e "${PROJECT_DIR}/CHANGELOG.md" ]]; then
    range=""
    "${gcliff[@]}" --
 else
    range=(-u -- "$(git -C "${PROJECT_DIR}" describe --abbrev=0 --tags)..HEAD")
    "${gcliff[@]}" "${range[@]}"
  fi

  sed -i "s/### Build/### 🔨 Build/g" "${PROJECT_DIR}/CHANGELOG.tmp.md"
  sed -i "s/### Wip/### 🚧 Wip/g" "${PROJECT_DIR}/CHANGELOG.tmp.md"
  sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "${PROJECT_DIR}/CHANGELOG.tmp.md"
  sed -i 's/\r$//' "${PROJECT_DIR}/CHANGELOG.tmp.md"

  # check if the current commit is tagged
  if ! git describe --exact-match --tags HEAD >/dev/null 2>&1; then
    # If not, use $(git rev-parse HEAD) to get the commit hash
    commit_hash=$(git -C "${PROJECT_DIR}" rev-parse HEAD)

    # Include content of version.txt under the ## [unreleased] - line
    version_content=$(sed '1d' "${PROJECT_DIR}/version.txt")  # Remove the first line
    echo "${version_content}" > "${PROJECT_DIR}/version.tmp.txt"
    sed -i "/## \[unreleased\] -/r ${PROJECT_DIR}/version.tmp.txt" "${PROJECT_DIR}/CHANGELOG.tmp.md"

    # Extract the version and title from the first line of version.txt
    read -r version version_title < <(head -n 1 "${PROJECT_DIR}/version.txt" | awk -F ' -- ' '{print $1, $2}')

    # Modify the ## [unreleased] - line with the version, title, and commit hash
    sed -i "s/## \[unreleased\] -/## [v${version} unreleased] ${version_title} - ${commit_hash}/" "${PROJECT_DIR}/CHANGELOG.tmp.md"    
  fi

  if [[ -z "${range}" ]]; then
    mv "${PROJECT_DIR}/CHANGELOG.tmp.md" "${PROJECT_DIR}/CHANGELOG.md"
  else
    # Replace lines in CHANGELOG.md until the first occurrence of ## [vx.y.z] with the content of CHANGELOG.tmp.md
    sed -i '/^## \[v[0-9]\+\.[0-9]\+\.[0-9]\+\]/,$!d' "${PROJECT_DIR}/CHANGELOG.md"
    (cat "${PROJECT_DIR}/CHANGELOG.tmp.md"; echo ""; cat "${PROJECT_DIR}/CHANGELOG.md") > "${PROJECT_DIR}/CHANGELOG.new.md"
    mv "${PROJECT_DIR}/CHANGELOG.new.md" "${PROJECT_DIR}/CHANGELOG.md"
  fi
}

main "$@"
