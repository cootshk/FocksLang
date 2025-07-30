---@diagnostic disable: duplicate-set-field

-- Waiting on real lux compiling (luastatic?) support
---@type function
local write
local success, _ = pcall(function()
	write = require("pl.pretty").write
end)
if not success then
	write = function(tbl)
		local i = 1
		---@type string
		local output = ""
		for k, v in pairs(tbl) do
			---@type string
			output = output .. "\n" .. i .. ". " .. k .. " = " .. v
		end
		return output:sub(2)
	end
end

_G.log = function(...)
	if not ENABLE_LOGS then
		return
	end
	local args = { ... }
	for i, v in ipairs(args) do
		if type(v) == "table" then
			args[i] = write(v)
		end
	end
	print(table.concat(args, " "))
end
