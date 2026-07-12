#!/bin/bash
# pinentry-wrapper.sh - launch the relocated pinentry-tty for gpg-agent.
#
# gpg-agent execs its pinentry directly, outside any login environment,
# and the pinentry-tty shipped under tools/git/root needs its own
# shared libraries (libsecret-1.so.0 and friends live in
# tools/git/root/usr/lib64, off the default loader path): launched
# bare, it dies on 'error while loading shared libraries', which
# gpg-agent reports as the terse 'No pinentry'. This wrapper puts that
# lib64 on LD_LIBRARY_PATH, then hands over.
#
# Paths resolve relative to this file, which lives in tools/certs next
# to gpg-agent.conf, with tools/git/root one hop away: the wrapper
# works unchanged in any installation prefix, and carries no
# rewritable home literal for the relocation text pass to mangle.
certs_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
git_root="${certs_dir}/../git/root"
export LD_LIBRARY_PATH="${git_root}/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
exec "${git_root}/usr/bin/pinentry-tty" "$@"
