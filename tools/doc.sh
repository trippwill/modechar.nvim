#!/bin/sh

# Generate documentation for the modechar.nvim plugin using vimcats.
# Run this script from the root of the repository:
# $ sh tools/docs.sh

mkdir -p "$PWD/doc"
cargo install vimcats --features=cli
vimcats -c -a -t -f \
  lua/modechar/init.lua \
  lua/modahl/init.lua \
  lua/modahl/modes.lua \
  >"$PWD/doc/modechar.nvim.txt"

less "$PWD/doc/modechar.nvim.txt"
