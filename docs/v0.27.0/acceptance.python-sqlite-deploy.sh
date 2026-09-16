#!/bin/bash
# Bootstrap one consumer from pinned verification material and the same archive.
# No compilation, package installation, loader override, or live-tree mutation.
set -euo pipefail
[[ $# -ge 9 ]] || { echo 'usage: deploy ROLE HOME BUNDLE BUNDLE_SHA ARCHIVE ARCHIVE_SHA REVISION PARSER DRIVER_OPTIONS...' >&2; exit 2; }
role=$1 home=$2 bundle=$3 bundle_sha=$4 archive=$5 archive_sha=$6 revision=$7 parser=$8
shift 8
[[ $role == rhel || $role == debian ]]
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=docs/v0.27.0/acceptance.python-sqlite-capture.sh
source "$here/acceptance.python-sqlite-capture.sh"
sqlite_anchor "$home" "$role"
[[ -z $(find "$home" -mindepth 1 -print -quit) ]]
[[ $bundle_sha =~ ^[0-9a-f]{64}$ && $archive_sha =~ ^[0-9a-f]{64}$ && $revision =~ ^[0-9a-f]{40}$ ]]
[[ $(sqlite_digest "$bundle") == "$bundle_sha" && $(sqlite_digest "$archive") == "$archive_sha" ]]
mkdir "$home/verification" "$home/evidence" "$home/tools" "$home/pkgs"
# The bundle is an independently pinned git archive of source controls plus
# reviewed acceptance scripts. Reject paths outside its two permitted roots.
tar -tzf "$bundle" > "$home/evidence/bundle.entries"
while IFS= read -r path; do
    path=${path#./}
    [[ -z $path || $path == src || $path == src/* || $path == acceptance || $path == acceptance/* ]]
    [[ /$path/ != *'/../'* ]]
done < "$home/evidence/bundle.entries"
tar -xzf "$bundle" -C "$home/verification"
sqlite_boundary "$home/verification"
source_root=$home/verification/src
cp -a "$source_root/setups/env" "$home/cplx"
mkdir -p "$home/cplx/bin" "$home/cplx/echos" "$home/cplx/tools"
cp -a "$source_root/utils/." "$home/cplx/bin/"
cp -a "$source_root/echos/." "$home/cplx/echos/"
cp -a "$source_root/install/env/." "$home/cplx/tools/"
cat > "$home/.env" <<'ENV'
source "${HOME}/.env_"
ENV
cat > "$home/.env_" <<'ENV'
source "${HOME}/tools/.env_init"
ENV
printf 'services=git,python\n' > "$home/cplx/cplx.properties"
printf 'TERM=dumb\nUSER=%s\nLOGNAME=%s\n' "$(id -un)" "$(id -un)" > "$home/scalars"
cp -- "$archive" "$home/pkgs/tools.sqlite-candidate.tar.gz"
[[ $(sqlite_digest "$home/pkgs/tools.sqlite-candidate.tar.gz") == "$archive_sha" ]]
(
    cd "$home"
    find cplx -type f -print0
    printf '%s\0' .env .env_ scalars
) > "$home/evidence/control.paths"
(cd "$home" && xargs -0 sha256sum -- < evidence/control.paths) > "$home/evidence/audit"
audit_sha=$(sqlite_digest "$home/evidence/audit")
printf 'revision=%s\nbundle_sha256=%s\narchive_sha256=%s\naudit_sha256=%s\n' \
    "$revision" "$bundle_sha" "$archive_sha" "$audit_sha" > "$home/evidence/inputs"
args=(--home "$home" --role "$role" --evidence "$home/evidence" --parser "$parser"
    --audit "$home/evidence/audit" --audit-sha256 "$audit_sha" --settings "$home/scalars"
    --revision "$revision" --probe "$home/cplx/tools/python/sqlite_probe.py"
    --archive "$home/pkgs/tools.sqlite-candidate.tar.gz" --sha256 "$archive_sha"
    --expected-python-root "$home/tools/python"
    --expected-extension-root "$home/tools/python/python-3.13.15/lib/python3.13/lib-dynload"
    --expected-provider "$home/tools/python/root/usr/lib64/libsqlite3.so.0" "$@")
for phase in preflight deploy probe; do
    # The pinned archive carries the two exact bootstrap files above. Every
    # phase rechecks their original hashes, including after relocation.
    bash "$here/acceptance.python-sqlite-support.sh" "$phase" "${args[@]}"
done
