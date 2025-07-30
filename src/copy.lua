local type = require("globals").type

-- Hard Copy
---@type any[t]
---@return any[t]
local function copy(o)
	if type(o) ~= "table" then
		return o
	end
	local ret = {}
	for k, v in pairs(o) do
		ret[k] = copy(v)
	end
	setmetatable(ret, getmetatable(o))
	return ret
end
return copy
