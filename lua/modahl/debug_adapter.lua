--[[
This adapter maps modes to highly visible colors for debugging purposes.
]]

local modes = require("modahl.modes")

---@type ModahlAdapter
return {
  name = "debug",
  on_mode_change = function(_, curr, config)
    local color_map = {
      [modes.UNDEFINED] = { fg = "bg", bg = "fg" },
      [modes.NORMAL] = { fg = "#FF0000", bg = "#00FF00" },
      [modes.INSERT] = { fg = "#FFFF00", bg = "#0000FF" },
      [modes.VISUAL] = { fg = "#FF00FF", bg = "#00FFFF" },
      [modes.VISUAL_LINE] = { fg = "#FFA500", bg = "#800080" },
      [modes.VISUAL_BLOCK] = { fg = "#008000", bg = "#FFC0CB" },
      [modes.REPLACE] = { fg = "#0000FF", bg = "#FFFF00" },
      [modes.COMMAND] = { fg = "#00FFFF", bg = "#FF00FF" },
      [modes.SELECT] = { fg = "#800080", bg = "#FFA500" },
      [modes.TERMINAL] = { fg = "#FFC0CB", bg = "#008000" },
    }

    local color = color_map[curr]
    if not color then
      if config.debug then
        vim.notify("Invalid mode: " .. tostring(curr), vim.log.levels.ERROR)
      end
      return { fg = "NONE", bg = "NONE" }
    end

    return color
  end,
}
