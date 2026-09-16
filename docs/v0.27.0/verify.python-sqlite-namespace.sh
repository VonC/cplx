#!/bin/bash
# Native RHEL facility check, run explicitly through the existing SSH account.
# Creates disposable fixtures only; no build, packaging or deployment is run.
set -euo pipefail
printf 'fixture_utc=%s\n' "$(date -u +%FT%TZ)"
account_home=$(readlink -e -- "$HOME")
[[ $(id -u) != 0 && $account_home =~ ^/home/[^/]+$ && -O $account_home && -w $account_home ]]
backing=$(mktemp -d "$account_home/.cplx-sqlite-namespace.XXXXXXXX")
control=$(mktemp -d /var/tmp/cplx-sqlite-namespace.XXXXXXXX)
cleanup() {
    local result=$?
    if [[ -d $backing && ! -L $backing && $(readlink -e -- "$backing") == "$backing" &&
          $backing == "$account_home"/.cplx-sqlite-namespace.* && -f $backing/owned.fixture ]]; then
        rm -rf -- "$backing"
    fi
    if [[ -d $control && ! -L $control && $(readlink -e -- "$control") == "$control" &&
          $control == /var/tmp/cplx-sqlite-namespace.* && -f $control/owned.fixture ]]; then
        rm -rf -- "$control"
    fi
    exit "$result"
}
trap cleanup EXIT
touch "$backing/owned.fixture" "$control/owned.fixture"
mkdir "$backing/candidate" "$control/live"
printf 'candidate-only\n' > "$backing/candidate/sentinel"
stat -c '%d:%i' "$account_home" > "$control/home.before"
stat -c '%d:%i' "$backing/candidate" > "$control/candidate.before"
for path in "$account_home/cplx" "$account_home/tools" "$account_home/pkgs"; do
    stat -c '%n %d:%i %F' "$path"
done > "$control/live.before"
sha256sum "$account_home/.profile" "$account_home/.env" "$account_home/.env_" > "$control/controls.before"
# UID 0 exists only inside this new user namespace and maps to the SSH UID.
# This does not grant host-root access or modify the parent's mount namespace.
env -i HOME="$account_home" PATH=/usr/bin:/bin LANG=C LC_ALL=C \
    unshare --user --map-root-user --mount --propagation private \
    /bin/bash --noprofile --norc -s -- "$account_home" "$backing" "$control" <<'CHILD'
set -euo pipefail
account_home=$1 backing=$2 control=$3
# Leave inherited cwd behind before overlaying its ancestor.
cd /
mount --bind "$account_home" "$control/live"
mount -o remount,bind,ro "$control/live"
mount --bind "$backing/candidate" "$account_home"
cd "$account_home"
[[ $(stat -c '%d:%i' "$account_home") == "$(cat "$control/candidate.before")" ]]
[[ $(stat -c '%d:%i' "$control/live") == "$(cat "$control/home.before")" ]]
[[ $(cat sentinel) == candidate-only && ! -e .profile && ! -e .env ]]
findmnt --mountpoint "$control/live" -n -o VFS-OPTIONS | grep -qE '(^|,)ro(,|$)'
# Attempt a write only to our disposable fixture through the read-only view.
if touch "$control/live/${backing##*/}/blocked-write" 2> "$control/read-only.stderr"; then
    printf 'ERROR: live view was writable\n' >&2
    exit 2
fi
printf 'inside_namespace_uid=%s\n' "$(id -u)"
printf 'namespace_home_points_to_candidate=passed\n'
printf 'live_view_read_only=passed\n'
printf 'child-write\n' > namespace-result
CHILD
[[ $(cat "$backing/candidate/namespace-result") == child-write ]]
[[ ! -e $backing/blocked-write ]]
[[ $(stat -c '%d:%i' "$account_home") == "$(cat "$control/home.before")" ]]
for path in "$account_home/cplx" "$account_home/tools" "$account_home/pkgs"; do
    stat -c '%n %d:%i %F' "$path"
done > "$control/live.after"
cmp "$control/live.before" "$control/live.after"
sha256sum --check --status "$control/controls.before"
if findmnt --mountpoint "$control/live" >/dev/null; then
    printf 'ERROR: child mount visible in parent namespace\n' >&2
    exit 2
fi
printf 'outside_namespace_home_unchanged=passed\n'
printf 'outside_namespace_uid=%s\n' "$(id -u)"
printf 'live_root_identities_and_environment_hashes=unchanged\n'
printf 'fixture_result=passed (namespace capability only; no candidate acceptance)\n'
