#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix curl jq common-updater-scripts
#
# args:
#   1: path of upstream updatescript
#   2: plugin name
#   *: ?

set -eu -o pipefail

function cd() {
  unset -f cd
}

. "$@"
