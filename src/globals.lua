---@diagnostic disable: duplicate-set-field
local write = require("pl.pretty").write
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
