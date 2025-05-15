#!/bin/sh

# Generate documentation for the modechar.nvim plugin using vimcats.
# Run this script from the root of the repository:
# $ sh tools/docs.sh

mkdir -p "$PWD/doc"
cargo install vimcats --features=cli
vimcats lua/modahl/modes.lua \
  lua/modahl/init.lua \
  lua/modahl/debug_adapter.lua \
  lua/modahl/lualine_adapter.lua \
  lua/modahl/lualine-invert_adapter.lua \
  lua/modechar/init.lua >"$PWD/doc/modechar.nvim.txt"

less "$PWD/doc/modechar.nvim.txt"
