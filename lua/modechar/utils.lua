local M = {}

function M.deep_tostring(val, depth)
	depth = depth or 0
	local result = {}
	local padding = string.rep("  ", depth)

	for k, v in pairs(val) do
		local key = tostring(k)
		if type(v) == "table" then
			table.insert(result, padding .. key .. " = {\n" .. M.deep_tostring(v, depth + 1) .. padding .. "}")
		else
			table.insert(result, padding .. key .. " = " .. tostring(v))
		end
	end

	return table.concat(result, ",\n") .. "\n"
end

return M
