local M = {}

-- Returns a read-only table of strings
---@param t table<string>
---@return table<string>
function M.enum(t)
	if type(t) ~= "table" then
		error("Expected a table, got " .. type(t))
	end

	return setmetatable(t, {
		__newindex = function()
			error("Cannot modify enum")
		end,
		__metatable = false,
	})
end

-- Copies a value
---@param orig any
---@param meta? boolean -- true to copy the metatable
function M.deepcopy(orig, meta)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for key, value in next, orig, nil do
			copy[M.deepcopy(key, meta)] = M.deepcopy(value, meta)
		end
		if meta then
			setmetatable(copy, M.deepcopy(getmetatable(orig)))
		end
	else
		copy = orig
	end
	return copy
end

return M
