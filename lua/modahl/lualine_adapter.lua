--[[
This adapter retrieves the colors from the lualine 'a' section mode groups.
]]

local modes = require("modahl.modes")

-- Mode to lualine mapping
---@param mode Mode
---@return string | nil
local function mode_to_lualine(mode)
  local mode_map = {
    [modes.UNDEFINED] = "normal",
    [modes.NORMAL] = "normal",
    [modes.INSERT] = "insert",
    [modes.VISUAL] = "visual",
    [modes.VISUAL_LINE] = "visual",
    [modes.VISUAL_BLOCK] = "visual",
    [modes.REPLACE] = "replace",
    [modes.COMMAND] = "command",
    [modes.SELECT] = "command",
    [modes.TERMINAL] = "inactive",
  }
  return mode_map[mode]
end

---@type ModahlAdapter
return {
  name = "lualine",

  ---@param curr Mode
  on_mode_change = function(_, curr, config)
    local lualine_mode = mode_to_lualine(curr)
    if not lualine_mode then
      if config.debug then
        vim.notify("Unmapped lualine mode:" .. tostring(curr), vim.log.levels.WARN)
      end
      lualine_mode = "normal"
    end

    local lualine_group = "lualine_a_" .. lualine_mode
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = lualine_group, link = false })

    if ok and hl and hl.bg and hl.fg then
      -- return { fg = hl.bg, bg = hl.fg }
      return hl --[[@as vim.api.keyset.highlight]]
    end

    if config.debug then
      vim.notify("Failed to get lualine mode color for group: " .. lualine_group, vim.log.levels.WARN)
    end

    return { fg = "NONE", bg = "NONE" }
  end,
}
