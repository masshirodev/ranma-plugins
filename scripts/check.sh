#!/bin/bash
# Check plugins.json the way hako reads it, then load every plugin it lists
# into ranma. CI runs it against the latest ranma release; run it locally
# with any ranma on PATH.
#
#   scripts/check.sh              the file, then every plugin
#   scripts/check.sh FILE         another list file
#   HAKO_DIR=~/projects/hako.ranma scripts/check.sh   with a hako checkout
#                                 instead of the one on GitHub
#
# Needs ranma, git, and access to GitHub (the plugins are cloned).
# Everything it writes is in one temporary directory, removed at the end.
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
list=$(realpath "${1:-$here/plugins.json}")
work=$(mktemp -d "${TMPDIR:-/tmp}/ranma-plugins.XXXX")
trap 'rm -rf "$work"' EXIT

# ranma, isolated from whoever runs this: its own config, state, runtime and
# data directories, and no hako of its own (plugin_manager = "none").
run_ranma() { # config dir
  env -u RANMA_SOCKET -u RANMA_PANE -u RANMA XDG_RUNTIME_DIR="$work/rt" \
    XDG_STATE_HOME="$work/state" XDG_DATA_HOME="$work/data" XDG_CACHE_HOME="$work/cache" \
    RANMA_CONFIG_DIR="$1" RANMA_NO_UPDATE_CHECK=1 ranma --check-config
}
mkdir -p "$work/rt"
ranma --version

# 1. The file, read by hako's own reader (lua/hako/lists.lua), so the check is
#    what Browse will do, not a second copy of the rules.
if [ -n "${HAKO_DIR:-}" ]; then
  ln -s "$(realpath "$HAKO_DIR")" "$work/hako"
else
  git clone -q --depth 1 https://github.com/masshirodev/hako.ranma "$work/hako"
fi
mkdir -p "$work/cfg-list"
cat > "$work/cfg-list/init.lua" <<LUA
ranma.set { plugin_manager = "none" }
assert(ranma.packadd("$work/hako"))
local f = assert(io.open("$list"))
local list, err = require("hako.lists").parse(f:read("a"))
f:close()
if not list then error("$(basename "$list"): " .. err, 0) end
local out = assert(io.open("$work/repos", "w"))
for _, p in ipairs(list.plugins) do out:write(p.repo, " ", p.ranma or "0.0.0", "\n") end
out:close()
LUA
run_ranma "$work/cfg-list" > /dev/null
echo "ok   $(basename "$list") reads: $(wc -l < "$work/repos") plugins"

# 2. Every plugin loads (a plugin that fails is only a toast in a real config,
#    so packadd's error is turned into a failed check here).
have=$(ranma --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
older() { [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -1)" = "$1" ]; }
failed=0
while read -r repo needs; do
  case "$repo" in
    https://* | file://*) url=$repo ;;
    *) url=https://github.com/$repo ;;
  esac
  name=$(basename "${repo%.git}")
  if older "$have" "$needs"; then
    echo "skip $repo: needs ranma $needs, this is $have"
    continue
  fi
  if ! git clone -q --depth 1 "$url" "$work/plugins/$name" 2> "$work/err"; then
    echo "FAIL $repo: could not clone: $(head -1 "$work/err")"
    failed=1
    continue
  fi
  mkdir -p "$work/cfg-$name"
  cat > "$work/cfg-$name/init.lua" <<LUA
ranma.set { plugin_manager = "none" }
local ok, err = ranma.packadd("$work/plugins/$name")
if not ok then error("$name did not load: " .. tostring(err), 0) end
LUA
  if out=$(run_ranma "$work/cfg-$name" 2>&1); then
    echo "ok   $repo loads"
  else
    echo "FAIL $repo: $(printf '%s' "$out" | tail -3)"
    failed=1
  fi
done < "$work/repos"
exit "$failed"
