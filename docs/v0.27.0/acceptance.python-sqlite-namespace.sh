#!/bin/bash
# Run one acceptance command over an independent home in a private namespace.
# The physical home stays owned by the ordinary account. Nothing is removed.
set -euo pipefail
[[ $# -ge 5 && $4 == -- ]] || { echo 'usage: namespace HOME BACKING CONTROL -- COMMAND [ARG...]' >&2; exit 2; }
account_home=$1 backing=$2 control=$3
shift 4
[[ $(id -u) != 0 && $account_home =~ ^/home/[^/]+$ ]]
for path in "$account_home" "$backing" "$control"; do
    [[ -d $path && ! -L $path && -O $path && -w $path && $(readlink -e "$path") == "$path" ]]
done
[[ $backing == "$account_home"/.cplx-sqlite-run.*/home &&
   $control == /var/tmp/cplx-sqlite-run.* && ! -e $backing/.profile && ! -L $backing/.profile ]]
[[ -f $backing/../owned.run && -f $control/owned.run ]]
mkdir -p "$control/live"
[[ ! -L $control/live && -z $(find "$control/live" -mindepth 1 -print -quit) ]]
home_identity=$(stat -c '%d:%i' "$account_home")
backing_identity=$(stat -c '%d:%i' "$backing")
capture=$(mktemp -d "$control/invocation.XXXXXXXX")
printf 'home=%s\nbacking=%s\ncontrol=%s\nuid=%s\nhome_identity=%s\nbacking_identity=%s\n' \
    "$account_home" "$backing" "$control" "$(id -u)" "$home_identity" "$backing_identity" > "$capture/parent.before"
for path in "$account_home/.profile" "$account_home/.env" "$account_home/.env_"; do
    [[ ! -f $path ]] || sha256sum "$path"
done > "$capture/controls.before"
finish() {
    local status=$? preservation=0
    [[ $(stat -c '%d:%i' "$account_home") == "$home_identity" ]] || preservation=2
    sha256sum --check --status "$capture/controls.before" || preservation=2
    if findmnt --mountpoint "$control/live" >/dev/null; then preservation=2; fi
    printf 'command_exit=%s\nparent_preservation_exit=%s\n' "$status" "$preservation" > "$capture/result"
    ((preservation == 0)) || exit "$preservation"
    exit "$status"
}
trap finish EXIT
env -i HOME="$account_home" PATH=/usr/bin:/bin LANG=C LC_ALL=C \
    unshare --user --map-root-user --mount --propagation private \
    /bin/bash --noprofile --norc -s -- "$account_home" "$backing" "$control" "$capture" \
    "$home_identity" "$backing_identity" "$@" <<'CHILD'
set -euo pipefail
account_home=$1 backing=$2 control=$3 capture=$4 home_identity=$5 backing_identity=$6
shift 6
cd /
mount --bind "$account_home" "$control/live"
mount -o remount,bind,ro "$control/live"
mount --bind "$backing" "$account_home"
cd "$account_home"
[[ $(stat -c '%d:%i' "$account_home") == "$backing_identity" ]]
[[ $(stat -c '%d:%i' "$control/live") == "$home_identity" ]]
[[ ! -e .profile && ! -L .profile ]]
findmnt --mountpoint "$control/live" -n -o VFS-OPTIONS | grep -qE '(^|,)ro(,|$)'
[[ $(findmnt --mountpoint / -n -o PROPAGATION) == private ]]
cat /proc/self/uid_map > "$capture/uid_map"
findmnt --mountpoint "$account_home" > "$capture/home.mount"
findmnt --mountpoint "$control/live" > "$capture/live.mount"
printf 'namespace_uid=%s\ncommand=' "$(id -u)" > "$capture/command"
printf '%q ' "$@" >> "$capture/command"
printf '\n' >> "$capture/command"
exec "$@"
CHILD
