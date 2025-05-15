---@mod modechar.modahl Adapters
---@brief [[
--- A ModahlAdapter that inverts the colors of the lualine theme.
---@brief ]]

local lualine_adapter = require('modahl.lualine_adapter')

---Modahl lualine inverted adapter
---@type ModahlAdapter
return {
  name = 'lualine-invert',
  on_mode_change = function(_, curr, config)
    local base = lualine_adapter.on_mode_change(_, curr, config)
    if base then
      return { fg = base.bg, bg = 'NONE' }
    elseif config.debug then
      vim.notify('lualine-invert: no base color found', vim.log.levels.WARN)
    end

    return nil
  end,
}
