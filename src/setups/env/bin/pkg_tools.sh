#!/bin/bash

set -o pipefail

# Convenience front end over the canonical pkg.sh for the toolchain
# itself: packages the live tree ~/tools into ~/pkgs (pkg.sh adds
# ~/.env and ~/.env_ for the tools target). The counterpart of
# my-project's tools/pkg_pdfs.sh, producing the archive that ships
# the toolchain together with these relocation scripts.
# Extra arguments are passed through to pkg.sh, for example:
#   pkg_tools -- --exclude=tools/scratch

PKG_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -f "${PKG_TOOLS_DIR}/pkg.sh" ]; then
    echo " FATAL 1 : [pkg_tools.sh] pkg.sh not found next to this script (${PKG_TOOLS_DIR})" >&2
    exit 1
fi
exec bash "${PKG_TOOLS_DIR}/pkg.sh" tools "$@"
