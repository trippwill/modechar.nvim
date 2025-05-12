-- Defines the modes recognized by the modahl plugin. Neovim native mode strings are mapped to these values.

---@enum Mode
local mode = {
  UNDEFINED = 0,
  NORMAL = 1,
  INSERT = 2,
  VISUAL = 3,
  VISUAL_LINE = 4,
  VISUAL_BLOCK = 5,
  REPLACE = 6,
  COMMAND = 7,
  SELECT = 8,
  TERMINAL = 9,
}

return mode
