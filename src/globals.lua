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

local tonumber_old = _G.tonumber
---@param e num
---@param base int
---@return number
_G.tonumber = function(e, base)
	if type(base):sub(1, 5) == "focks" then
		base = base.value
	end
	if type(e):sub(1, 5) == "focks" then
		return tonumber_old(e.value, base)
	end
	return tonumber_old(e, base)
end

local type_old = _G.type
---@param object any
---@return string
function type(object)
	if type_old(object) == "table" and object.type then
		return object.type
	else
		return type_old(object)
	end
end

---Checks if the value is inside the table
---@param list table
---@param value any
---@return boolean
function table.contains(list, value)
	for _, v in pairs(list) do
		if v == value then
			return true
		end
	end
	return false
end