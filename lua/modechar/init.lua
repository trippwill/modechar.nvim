-- modechar - Get a character Highlighted in the current mode

---@class CharDef : CharDefFilters
---@field [1] string -- the character to show (can be any string)
---@field highlight string -- highlight group name to use for the character.
---@field clear_hl? boolean -- whether to clear the highlight group after printing the character. default: true

---@class CharDefFilters
---@field floats? boolean | string -- whether to show the character in floating windows. default: false
---@field inactive? boolean | string -- whether to show the character in inactive windows. default: false
---@field buftype? string | string[] | true -- a list of buffer types to show the character in. default: "" (normal buffers)
---@field fallback? string -- fallback character to use if the ModeChar is excluded by the filters. default: ""

---@class ModeCharOptions
---@field chars? table<string, CharDef> | fun(arg: string): CharDef -- a table of ModeChar indexed by name or an equivalent function
---@field char_filter? CharDefFilters -- default filters to use for all characters. default: { floats = false, inactive = false, buftype = { "" = true }, fallback = "" }
---@field debug? boolean | number -- debug level. default: false

---@alias GetChar fun(name: string, winid?: number): string -- function to get the character to display by name

---@class ModeCharModule
---@field defaults ModeCharOptions -- default options for the ModeChar module
---@field options ModeCharOptions | nil -- current options for the ModeChar module
---@field setup fun(opts: ModeCharOptions) -- function to setup the ModeChar module
---@field get GetChar -- function to get the character to display by name
---@field is_valid_window fun(winid: number, chardef: CharDef): boolean -- function to validate a window against the filters
local M = {}

_G.ModeChar = M

---@type ModeCharOptions
M.defaults = {
  chars = {
    gutter = { "\u{258c}", highlight = "Modahl" },
  },
  char_filter = {
    floats = false,
    inactive = false,
    buftype = "", -- only show in normal buffers
    fallback = "",
  },
}

---@type ModeCharOptions | nil
M.options = nil

-- Setup the ModeChar plugin
---@param opts ModeCharOptions
function M.setup(opts)
  local config = vim.tbl_deep_extend("force", M.defaults, opts or {})

  if config.debug then
    vim.notify("ModeChar: setup() called with options:\n" .. vim.inspect(config), vim.log.levels.DEBUG)
  end

  -- Validate the options
  if type(config.chars) ~= "table" and type(config.chars) ~= "function" then
    vim.notify("ModeChar: chars must be a table or a function", vim.log.levels.ERROR)
    return
  end

  M.options = config
end

-- Get the character to display by name
---@param name string - the index of the opts.chars table or function
---@param winid? number - provide to check filters against the window, or nil to use g.statusline_winid
---@return string -- the character to show
function M.get(name, winid)
  if not M.options then
    vim.notify_once("ModeChar: setup() must be called before using get()", vim.log.levels.ERROR)
    return ""
  end

  local ef_key = "expanded_fallback"
  local chardef = M.options.chars[name]
  if not chardef then
    return M.options.char_filter.fallback or ""
  end

  local final_char = "%*"
  if type(chardef.clear_hl) == "boolean" and not chardef.clear_hl then
    final_char = ""
  end

  if not chardef[ef_key] then
    -- if fallback is nil or empty use the empty string
    -- otherwise use the higlight group and fallback character
    local fallback_char = chardef.fallback or M.options.char_filter.fallback or ""
    local expanded_fallback = ""
    if fallback_char ~= "" then
      expanded_fallback = "%#" .. chardef.highlight .. "#" .. fallback_char .. final_char
    end
    chardef[ef_key] = expanded_fallback
  end

  winid = winid or vim.g.statusline_winid
  if not M.is_valid_window(winid, chardef) then
    return chardef[ef_key]
  end

  return "%#" .. chardef.highlight .. "#" .. chardef[1] .. final_char
end

--- Validate window filters
---@private
---@package
---@param winid number
---@param chardef CharDef
---@return boolean
function M.is_valid_window(winid, chardef)
  local floats = chardef.floats or M.options.char_filter.floats
  if not floats and vim.api.nvim_win_get_config(winid).relative ~= "" then
    return false
  end

  local inactive = chardef.inactive or M.options.char_filter.inactive
  if not inactive and vim.api.nvim_get_current_win() ~= winid then
    return false
  end

  local buftype = chardef.buftype or M.options.char_filter.buftype
  if type(buftype) == "string" then
    buftype = { buftype }
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  if bufnr and type(buftype) == "table" and not vim.tbl_contains(buftype, vim.bo[bufnr].buftype) then
    return false
  end

  return true
end

return M
