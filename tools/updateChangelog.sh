#!/bin/bash

# compute script_dir (the folder above the one with this script)
script_dir=$(dirname "$(dirname "$(realpath "$0")")")

ver="${1}"
title="${2}"
cd "${script_dir}"||exit 1
if grep -E "## $ver\b" CHANGELOG.md > /dev/null; then
  echo "ver detected '${ver}'"
  if ! (awk -v ver="$ver" '/## '"$ver"'([^[:alnum:]_]|$)/{print;system("cat CHANGELOG.tmp.md");f=1;next} f && /^## /{f=0} !f' CHANGELOG.md > temp.md && sed -i "s/## $ver - .*$/## ${ver} - $title/" temp.md &&  mv temp.md CHANGELOG.md); then
    echo "awk failed"
    exit 1
  fi
  echo "awk done with title '${title}'"
else
  echo "ver not detected"
  sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' CHANGELOG.md
  { echo; echo "## $ver - ${title}" >> CHANGELOG.md; } >> CHANGELOG.md
  cat CHANGELOG.tmp.md >> CHANGELOG.md
  echo "CHANGELOG.md completed"
fi
sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' CHANGELOG.md
sed -i 's/\r$//' "CHANGELOG.md"
sed -i 's/CHAGELOG.md/CHANGELOG.md/g' "CHANGELOG.md"
