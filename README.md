# modechar.nvim

A Neovim extension that provides user-defined characters with a
HilightGroup tied to the current mode.

## Features

- Get customizable character to display in the gutter
or other UI elements based on the current mode.
- Supports user-defined highlight groups for normal and inverted characters.
- Configurable filters for floating windows, inactive windows, and buffer types.
- Integration with lualine for dynamic color updates.
- Debugging options for advanced users.

## Roadmap

- Better integration with plugin managers
- Logging to a file

## Installation

Use your favorite plugin manager to install `modechar.nvim`. For example, with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'tripp/modechar.nvim',
  config = function()
    require('modechar').setup()
  end
}
```

## Configuration

You can configure `modechar.nvim` by passing options to the `setup` function.
Below is an example configuration:

```lua
require('modechar').setup({
  chars = {
    gutter = {
      "\u{258c}"
      -- override any fields in the char_filter table
      inactive = true,
    },
    arrow = { "\u{2794}", inverted=true }, -- Character to display as an arrow
  },
  colors = function(mode)
    return require('modechar').lualine(mode) -- Get colors dynamically from lualine
  end,
  hl = "ModeCharGroup", -- Highlight group for the character
  hl_inverted = "ModeCharGroupInverted", -- Highlight group for the inverted character
  char_filter = {
    floats = false, -- Disable in floating windows
    inactive = false, -- Disable in inactive windows
    buftype = "", -- Only show in normal buffers
    fallback = "", -- Fallback character if filters exclude the current one
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
vim.o.statuscolumn = [[%!v:lua.require'modechar'.get('gutter') .. v:lua.require'snacks.statuscolumn'.get()]]
```

### Highlighting Modes

The plugin automatically updates the highlight groups when the mode changes.
You can customize the colors by using the `colors` option.

### Debugging

Enable debugging by setting the `debug` option to `true` or a number:

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

### Integration with lualine

The plugin integrates with lualine to dynamically fetch colors for the current mode.
Ensure you have lualine installed and configured, or define your own colors in
the `colors` function/table.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

Licensed under the GPL-3.0 License. See [LICENSE](LICENSE) for details.
