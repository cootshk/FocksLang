-- All builtins here are exposed to end users
local objects = require("objects")
local old = require("globals")

---@type table, string, focksObject
local memory = {
-- GENERAL
	---@param arg focksObject
	print = function(arg)
		print(arg.value)
	end,
	---@param arg focksObject
	write = function(arg)
		io.write(arg.value)
	end,
	---@param arg focksObject
	---@return str
	read = function(arg)
		_G.MEMORY.write(arg)
		---@type focksString
		local input = io.read()
		if not input then
			error("Error reading input!")
		end
		return objects.string(input)
	end,
	---@param arg focksString
	set = function(arg)
		if not type(arg):match("tring", 2) then
			error("You can only use strings as variable names!")
		end
		---@param arg2 focksObject
		return function(arg2)
			local old_value
			pcall(function()
				old_value = MEMORY[arg.value]
			end)
			MEMORY[arg.value] = arg2
			return old_value
		end
	end,
	get = function(arg1)
		return MEMORY[arg1.value]
	end,
-- STRING
	str = function(arg)
		return tostring(arg) or error("Invalid string: " .. tostring(arg))
	end,
	concat = function(arg1)
		return function(arg2)
			return objects.string(arg1 .. arg2)
		end
	end,
	---@param arg1 focksString
	---@return function
	contains = function(arg1)
		---@param arg2 focksObject
		---@return boolean
		return function(arg2)
			if type(arg1) == "focksString" then
				if string.find(arg1.value, tostring(arg2), 1, true) then
					return true
				end
			end
			return false
		end
	end,
-- INTEGER
	int = function(arg)
		return tonumber(arg) or error("Invalid integer: " .. tostring(arg))
	end,
	---@param arg1 focksInt
	add = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			return arg1 + arg2
		end
	end,
	---@param arg1 focksInt
	sub = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			return arg1 - arg2
		end
	end,
	mul = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			return arg1 * arg2
		end
	end,
	div = function(arg1)
		---@param arg2 focksInt
		---@return integer
		return function(arg2)
			if arg2 == 0 then
				error("Division by zero!")
			end
			return math.floor(arg1 / arg2)
		end
	end,
-- LITERALS
	-- these are also literals in lua lmao
	["true"] = true,
	["false"] = false,
	_VERSION = VERSION,
	_LUA_VERSION = _VERSION,
}
local out = {}
setmetatable(out, {
	---@param self table
	---@param key str
	__index = function(self, key)
		--[[if type(key) == "string" then
			error("Variable "..key.." is not defined!")
		else]]
		if type("key") == "focksString" then
			return self[key.value]
		end
	end,
	__newindex = function (self, k, v)
		rawset(self, k, objects.object(v))
	end
})
for k, v in pairs(memory) do
	out[k] = v
end
return out
