---@mod modechar.modechar.intro Introduction
---@brief [[
---ModeChar: A module that registers a character (or any string) by name
---with associated window filters and highlights. It can be used to display
---characters in the statusline, tabline, or any other place where you can
---use a string.
---
--->
---vim.o.statuscolumn = [[%!v:lua.require'modechar'.get('gutter') .. v:lua.require'snacks.statuscolumn'.get()]]
---<
---@brief ]]

---@mod modechar.modechar.types Types

---@class CharDef : CharDefFilters
---@field [1] string -- the character to show (can be any string)
---@field highlight 'ModeCharLualine' | 'ModeCharLualineInvert' | 'ModeCharDebug' | string -- highlight group name to use for the character.
---@field clear_hl? boolean -- whether to clear the highlight providedup after printing the character. default: true

---@class CharDefFilters
---@field floats? boolean | string -- whether to show the character in floating windows. default: false
---@field inactive? boolean | string -- whether to show the character in inactive windows. default: false
---@field buftype? string | string[] | true -- a list of buffer types to show the character in. default: "" (normal buffers)
---@field fallback? string -- fallback character to use if the ModeChar is excluded by the filters. default: ""

---@class ModeCharOptions
---@field chars? table<string, CharDef> | fun(arg: string): CharDef -- a table of ModeChar indexed by name or an equivalent function
---@field char_filter? CharDefFilters -- default filters to use for all characters. default: { floats = false, inactive = false, buftype = { "" = true }, fallback = "" }
---@field debug? boolean -- debug. default: false
---@field modahl_opts? ModahlOptions -- options for the Modahl module.

---@mod modechar.modechar Module

---@class ModeCharModule
local M = {}

---Default options.
---@type ModeCharOptions
M.defaults = {
  chars = {
    gutter = { '\u{258c}', highlight = 'ModeCharLualineInvert' },
  },
  char_filter = {
    floats = false,
    inactive = false,
    buftype = '', -- only show in normal buffers
    fallback = '',
  },
  debug = false,
  modahl_opts = {
    highlights = {
      {
        'ModeCharLualineInvert',
        adapter = 'lualine-invert',
      },
      {
        'ModeCharLualine',
        adapter = 'lualine',
      },
      {
        'ModeCharDebug',
        adapter = 'debug',
      },
    },
    debug = false,
  },
}

---@type ModeCharOptions | nil
---@package
---@private
M.config = nil

---Initialize the ModeChar module with the given options.
---@param opts ModeCharOptions | {}
function M.setup(opts)
  local config = vim.tbl_deep_extend('force', M.defaults, opts or {})

  if config.debug then
    vim.notify('ModeChar: setup() called with options:\n' .. vim.inspect(config), vim.log.levels.DEBUG)
  end

  -- Validate the options
  if type(config.chars) ~= 'table' and type(config.chars) ~= 'function' then
    vim.notify('ModeChar: chars must be a table or a function', vim.log.levels.ERROR)
    return
  end

  -- Setup Modahl if options are provided
  if type(config.modahl_opts) == 'table' then
    local modahl = require('modahl')
    local ok, res = pcall(modahl.setup, config.modahl_opts)
    if not ok then
      vim.notify('ModeChar: failed to setup Modahl: ' .. tostring(res), vim.log.levels.ERROR)
    end
  end

  M.config = config
end

---Get the character to display by name.
---@param name string -- the key of the opts.chars table or the arg to the function
---@param winid? number -- provide to check filters against the window, or nil to use g.statusline_winid
---@return _ string -- the character to show or the fallback character if excluded by filters
function M.get(name, winid)
  if not M.config then
    vim.notify_once('ModeChar: setup() must be called before using get()', vim.log.levels.ERROR)
    return ''
  end

  local chars = M.config.chars
  local default_fallback = M.config.char_filter.fallback or ''

  if not chars or (type(chars) ~= 'table' and type(chars) ~= 'function') then
    vim.notify('ModeChar: chars must be a table or a function', vim.log.levels.ERROR)
    return ''
  end

  -- Retrieve the character definition
  local chardef = (type(chars) == 'function' and chars(name)) or chars[name]
  if not chardef then
    return default_fallback
  end

  -- Handle highlight clearing
  local final_char = (chardef.clear_hl == false) and '' or '%*'

  -- Check if the character is excluded by the filters
  winid = winid or vim.g.statusline_winid
  if not M:is_valid_window(winid, chardef) or not chardef.highlight or not chardef[1] then
    return chardef.fallback or default_fallback or ''
  end

  -- Return the final character with highlight
  return '%#' .. chardef.highlight .. '#' .. chardef[1] .. final_char
end

--Validate window filters
---@private
---@param self ModeCharModule
---@param winid number
---@param chardef CharDef
---@return boolean
function M:is_valid_window(winid, chardef)
  local floats = chardef.floats or self.config.char_filter.floats
  if not floats and vim.api.nvim_win_get_config(winid).relative ~= '' then
    return false
  end

  local inactive = chardef.inactive or self.config.char_filter.inactive
  if not inactive and vim.api.nvim_get_current_win() ~= winid then
    return false
  end

  local buftype = chardef.buftype or self.config.char_filter.buftype
  if type(buftype) == 'string' then
    buftype = { buftype }
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  if bufnr and type(buftype) == 'table' and not vim.tbl_contains(buftype, vim.bo[bufnr].buftype) then
    return false
  end

  return true
end

return M
