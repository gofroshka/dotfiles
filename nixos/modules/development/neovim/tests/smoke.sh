#!/usr/bin/env bash
set -euo pipefail

module=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
flake=$(cd -- "$module/../../.." && pwd)
package=${NVIM_PACKAGE:-$(nix build --no-link --print-out-paths "path:$flake#neovim")}
tmp=$(mktemp -d /tmp/opencode/nvf-smoke.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT

export XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data"
export XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
export NVIM_SMOKE_SCRIPT="$module/tests/smoke.lua"
export NVIM_TEST_BINARY="$package/bin/nvim"
"$package/bin/nvim" -n --headless \
  '+lua dofile(vim.env.NVIM_SMOKE_SCRIPT)'
"$package/bin/nvim" -n --headless -u NONE -l "$module/tests/dashboard.lua"
