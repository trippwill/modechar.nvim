--[[
Modahl: A Neovim plugin for dynamically updating highlight groups based on mode changes.

Create new highlight groups and link them to existing ones, updating them based on the current mode in Neovim.
The atttributes for the highlight group updates are provided by the adapter. Three known adapters
are provided: "debug", "lualine", and "lualine-invert". The "debug" adapter is the default if not configured.

The known adapters are configured by name:
{
  "MyOtherHighlightIsAPorche",
  adapter = "lualine",
}

A custom adapter can easily be created inline:
{
  "MyCustomGroup",
  ---@type ModahlAdapter
  adapter = {
    name = "MyCustomAdapter",
    on_mode_change = function(prev, curr, config)
      local modes = require("modahl.modes")
      if curr == modes.NORMAL then
        return { fg = "red", bg = "blue" }
      elseif curr == modes.INSERT then
        return { fg = "green", bg = "yellow" }
      else
        return { fg = "white", bg = "black" }
      end
    end,
  },
}

]]

---@class ModahlAdapter
---@field name string
---@field on_mode_change fun(prev: Mode, curr: Mode, config: ModahlOptions): vim.api.keyset.highlight | nil

---@class HighlightGroupDefinition
---@field [1]? string
---@field adapter? ModahlAdapter | "debug" | "lualine" | "lualine-invert"
---@field links? string[]

---@class ModahlOptions
---@field highlights? HighlightGroupDefinition[]
---@field autocmd_group? string
---@field mode_map? table<string, Mode>
---@field debug? boolean | "verbose"

---@class ModahlModule
---@field setup fun(opts: ModahlOptions)
---@field defaults ModahlOptions
---@field config? ModahlOptions
local M = {}

local modes = require("modahl.modes")
local known_adapters = { "debug", "lualine", "lualine-invert" }
local default_hlname = "Modahl"

---@type ModahlOptions
M.defaults = {
  highlights = {
    {
      default_hlname,
      adapter = "debug",
      links = {},
    },
  },
  autocmd_group = "ModahlGroup",
  mode_map = {
    n = modes.NORMAL,
    no = modes.NORMAL,
    ni = modes.NORMAL,
    i = modes.INSERT,
    ic = modes.INSERT,
    v = modes.VISUAL,
    V = modes.VISUAL_LINE,
    [""] = modes.VISUAL_BLOCK,
    s = modes.SELECT,
    S = modes.SELECT,
    R = modes.REPLACE,
    Rv = modes.REPLACE,
    c = modes.COMMAND,
    t = modes.TERMINAL,
  },
  debug = false,
}

local function setup_mode_change_listener(config)
  vim.api.nvim_create_autocmd({ "ModeChanged", "BufEnter" }, {
    group = config.autocmd_group,
    callback = function()
      local prev_mode = M.prev_mode or modes.UNDEFINED
      local curr_mode = config.mode_map[vim.fn.mode()] or nil

      if not prev_mode or not curr_mode then
        if config.debug then
          vim.notify(
            "Invalid mode change detected: " .. (prev_mode or "nil old_mode") .. " -> " .. (curr_mode or "nil new_mode"),
            vim.log.levels.WARN
          )
        end
        return
      end

      for _, group in ipairs(config.highlights) do
        local adapter = group.adapter
        local attributes = adapter.on_mode_change(prev_mode, curr_mode, config)
        if attributes then
          if config.debug == "verbose" then
            vim.notify(
              "Adapter "
                .. (group.adapter.name or "unnamed adapter")
                .. " returned attributes for mode change: "
                .. vim.inspect(attributes),
              vim.log.levels.TRACE
            )
          end
          vim.schedule(function()
            vim.api.nvim_set_hl(0, group[1], attributes)
          end)
        elseif config.debug == "verbose" then
          vim.notify("Adapter " .. group.adapter .. " did not return attributes for mode change", vim.log.levels.TRACE)
        end
      end

      M.prev_mode = curr_mode
    end,
  })
end

---@param config ModahlOptions
local function setup_highlight_groups(config)
  local hl_groups = config.highlights or {}
  for _, group in ipairs(hl_groups) do
    local group_name = group[1] or nil
    local adapter = group.adapter or nil
    local links = group.links

    if not group_name then
      vim.notify("Invalid highlight group name", vim.log.levels.ERROR)
      return
    end

    if not adapter then
      vim.notify("Invalid adapter for group: " .. group_name, vim.log.levels.ERROR)
      return
    end

    local mode = config.mode_map[vim.fn.mode()] or modes.UNDEFINED
    if mode == modes.UNDEFINED and config.debug then
      vim.notify("Invalid mode for group: " .. group_name, vim.log.levels.DEBUG)
    end

    local hl_attributes = adapter.on_mode_change(modes.UNDEFINED, mode, config) or { fg = "NONE", bg = "NONE" }

    -- Define the highlight group
    vim.api.nvim_set_hl(0, group_name, hl_attributes)

    -- Set up links for the highlight group
    for _, link in ipairs(links or {}) do
      vim.api.nvim_set_hl(0, link, { link = group_name })
    end
  end
end

-- Setup function to initialize Modahl
---@param opts ModahlOptions
function M.setup(opts)
  -- Merge user options with defaults
  local config = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})

  for _, group in ipairs(config.highlights) do
    local adapter = group.adapter

    if type(group[1]) ~= "string" then
      if config.debug then
        vim.notify("Using default highlight group name " .. default_hlname, vim.log.levels.DEBUG)
      end
      group[1] = default_hlname
    end

    if type(adapter) ~= "table" or not adapter.on_mode_change then
      if type(adapter) == "string" and vim.tbl_contains(known_adapters, adapter) then
        group.adapter = require("modahl." .. group.adapter .. "_adapter")
      else
        group.adapter = require("modahl.debug_adapter")
        vim.notify("Invalid adapter for group: " .. group[1], vim.log.levels.ERROR)
      end
    end
  end

  if config.debug then
    vim.notify("Modahl: setup() with options: " .. vim.inspect(config), vim.log.levels.DEBUG)
  end

  -- Set up highlight groups
  setup_highlight_groups(config)

  -- Create autocommand group
  vim.api.nvim_create_augroup(config.autocmd_group, { clear = true })

  -- Set up mode change listener
  setup_mode_change_listener(config)

  -- Store the configuration for later use
  M.config = config
end

return M
