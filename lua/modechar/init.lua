-- modechar - Get a character Highlighted in the current mode

---@class CharDef : CharDefFilters
---@field [1] string -- the character to show (can be any string)
---@field inverted? boolean -- whether to show the inverted character. default: false

---@class CharDefFilters
---@field floats? boolean | string -- whether to show the character in floating windows. default: false
---@field inactive? boolean | string -- whether to show the character in inactive windows. default: false
---@field buftype? string | string[] -- a list of buffer types to show the character in. default: ""
---@field fallback? string -- fallback character to use if the ModeChar is excluded by the filters. default: ""

---@class ColorDef : vim.api.keyset.highlight
---@field fg string
---@field bg? string

---@class ModeCharOptions
---@field chars? table<string, CharDef> | fun(arg: string): CharDef -- a table of ModeChar indexed by name or an equivalent function
---@field colors? table<string, ColorDef> | fun(arg: string): ColorDef -- table of ColorDef indexed by mode or an equivalent function
---@field hl? string -- highlight group name to use for the character. default: "ModeCharGroup"
---@field hl_inverted? string -- highlight group name to use for the inverted character. default: "ModeCharGroupInverted"
---@field char_filter? CharDefFilters -- default filters to use for all characters. default: { floats = false, inactive = false, buftype = { "" = true }, fallback = "" }
---@field debug? boolean | number -- debug level. default: false

---@alias GetChar fun(name: string, winid?: number): string -- function to get the character to display by name

---@class ModeCharConfig
local M = {}
local utils = require("modechar.utils")

M.meta = {
	name = "modechar",
	desc = "Get a character Highlighted in the current mode",
	version = "0.1",
}

---@type ModeCharConfig
_G.ModeChar = M

---@type ModeCharOptions
M.options = {
	chars = {
		gutter = { "\u{258c}" },
	},
	colors = function(mode)
		return M.lualine(mode) -- get the color from lualine
	end,
	hl = "ModeCharGroup",
	hl_inverted = "ModeCharGroupInverted",
	char_filter = {
		floats = false,
		inactive = false,
		buftype = "", -- only show in normal buffers
		fallback = "",
	},
}

---@type string
M.current_mode = nil

---@type ColorDef
M.current_color = nil

---@type ColorDef
M.current_inverted = nil

-- Setup the ModeChar plugin
---@param opts ModeCharOptions
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})

	if M.options.debug then
		vim.notify("ModeChar: setup() called with options:\n" .. vim.inspect(M.options), vim.log.levels.INFO)
	end

	-- Validate the options
	if type(M.options.chars) ~= "table" and type(M.options.chars) ~= "function" then
		vim.notify("ModeChar: chars must be a table or a function", vim.log.levels.ERROR)
		return
	end

	if type(M.options.colors) ~= "table" and type(M.options.colors) ~= "function" then
		vim.notify("ModeChar: colors must be a table or a function", vim.log.levels.ERROR)
		return
	end

	-- update current_mode and current_color when mode changes
	vim.api.nvim_create_autocmd({
		"ModeChanged",
		"BufEnter",
	}, {
		callback = function()
			vim.schedule(M.mode_changed)
		end,
	})

	-- initialize the current mode and color
	M.mode_changed()
	vim.g.modechar_setup = true
end

-- Get the character to display by name
---@param name string - the index of the opts.chars table or function
---@param winid? number - provide to check filters against the window, or nil to use g.statusline_winid
---@return string -- the character to show
function M.get(name, winid)
	if not vim.g.modechar_setup then
		vim.notify_once("ModeChar: setup() must be called before using get()", vim.log.levels.ERROR)
		return ""
	end

	local chardef = M.options.chars[name]
	if not chardef then
		return M.options.char_filter.fallback or ""
	end

	local inverted = chardef.inverted or false
	local hl = inverted and M.options.hl_inverted or M.options.hl

	-- if fallback is nil or empty use the empty string
	-- otherwise use the higlight group and fallback character
	local fallback = chardef.fallback or M.options.char_filter.fallback or ""
	if fallback ~= "" then
		fallback = "%#" .. hl .. "#" .. fallback .. "%*"
	end

	winid = winid or vim.g.statusline_winid
	if not M.is_valid_window(winid, chardef) then
		return fallback
	end

	return "%#" .. hl .. "#" .. chardef[1] .. "%*"
end

-- Get the current mode color from lualine
---@param mode string
---@return ColorDef
function M.lualine(mode)
	local lualine_mode = M.mode_to_lualine[mode] or "normal"
	local lualine_group = "lualine_a_" .. lualine_mode
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = lualine_group, link = false })
	if not ok or not hl or not hl.bg or not hl.fg then
		return { fg = "NONE", bg = "NONE" }
	else
		return { fg = string.format("#%06x", hl.bg), bg = string.format("#%06x", hl.fg) }
	end
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

-- Callback invoked when the mode changes
---@package
function M.mode_changed()
	M.current_mode = vim.fn.mode()
	M.current_color = (type(M.options.colors) == "function" and M.options.colors(M.current_mode))
		or M.options.colors[M.current_mode]
		or { fg = "NONE", bg = "NONE" }
	M.current_inverted = { fg = M.current_color.bg, bg = M.current_color.fg }
	vim.api.nvim_set_hl(0, M.options.hl, M.current_color)
	vim.api.nvim_set_hl(0, M.options.hl_inverted, M.current_inverted)
end

M.mode_to_lualine = {
	n = "normal",
	no = "normal",
	ni = "normal",
	i = "insert",
	ic = "insert",
	v = "visual",
	V = "visual",
	["\22"] = "visual",
	s = "visual",
	S = "visual",
	R = "replace",
	Rv = "replace",
	c = "command",
	t = "insert",
}

return M
