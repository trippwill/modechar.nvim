# modechar.nvim

> [!NOTE]
> This plugin is in early development and may not be fully functional. Use at your own risk.
> This README is a work in progress and may not contain all the necessary information.

A Neovim extension that provides user-defined characters with a HighlightGroup and filters for the current window.

## Features

- Get customizable characters to display in the gutter or other UI elements based on window filters.
  - Configurable filters for floating windows, inactive windows, and buffer types.
- Works seamlessly with the `modahl` plugin (also in this repo) for dynamic highlight group updates.

## Roadmap

- Better integration with plugin managers.
- Logging to a file.

## Installation

Use your favorite plugin manager to install `modechar.nvim`. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "trippwill/modechar.nvim",
  module = "modechar",
  opts = {
    chars = {
      gutter = { "▌", highlight = "ModeCharGutter", clear_hl = true, buftype = { "", "nofile" } },
      arrow = { "▶", highlight = "Modahl" },
    },
    debug = false,
  },
}
```

## Configuration

You can configure `modechar.nvim` by passing options to the `setup` function. Below is an example configuration:

```lua
require('modechar').setup({
  chars = {
    gutter = { '▌', highlight = 'ModeCharGutter', clear_hl = true, buftype = { '', 'nofile' } },
    arrow = { '▶', highlight = 'Modahl' },
  },
  char_filter = {
    floats = false, -- Disable in floating windows
    inactive = false, -- Disable in inactive windows
    buftype = '', -- Only show in normal buffers
    fallback = '', -- Fallback character if filters exclude the current one
  },
  debug = false, -- Set to true or a number for debug output
})
```

## Usage

### Displaying Characters

To get a character by name, use the `get` function:

```lua
local char = require('modechar').get('gutter')
print(char)
```

To use the character in your statuscolumn or other UI elements:

```lua
vim.o.statuscolumn = [[%!v:lua.require'modechar'.get('gutter')]]
```

You can dynamically change the colors by defining highlight groups in the `modahl` plugin.

### Debugging

Enable debugging by setting the `debug` option to `true`:

```lua
require('modechar').setup({
  debug = true,
})
```

## Advanced

### Filters

You can use filters to control where the characters are displayed. For example:

- `floats`: Set to `true` to enable in floating windows.
- `inactive`: Set to `true` to enable in inactive windows.
- `buftype`: Specify buffer types where the character should appear.

### Integration with modahl

The `modechar` plugin works well with the `modahl` plugin to dynamically update highlight groups based on the current mode. Configure `modahl` by including `modahl_opts` in the `modechar` opts. For example:

```lua
---@module 'modechar'
{
  "trippwill/modechar.nvim",
  module = "modechar",
  ---@type ModeCharOptions
  opts = {
    chars = {
      gutter = { "▌", highlight = "ModeCharGutter", clear_hl = true, buftype = { "", "nofile" } },
      arrow = { "▶", highlight = "Modahl" },
    },
    debug = false,
    modahl_opts = {
      highlights = {
        {
          "ModeCharGutter",
          adapter = "lualine-invert",
        },
        {
          "ModeCharArrow",
          adapter = "debug",
          links = { "CursorColumn" },
        },
      },
      debug = false,
    },
  },
}
```

`modahl` can also be used on it's own.

### Integration with lualine

The plugin integrates with lualine to dynamically fetch colors for the current mode. Ensure you have lualine installed and configured, then use the `lualine` or `lualine-invert` adapters provided by the `modahl` plugin.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

Licensed under the GPL-3.0 License. See [LICENSE](LICENSE) for details.

