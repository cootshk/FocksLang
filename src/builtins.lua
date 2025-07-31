-- All builtins here are exposed to end users
local objects = require("objects")
local old = require("globals")

---@type table, string, focksObject
local ret = {
	---@type focksFunction
	print = objects.func(function(arg)
		print(arg.value)
	end),
	---@param arg focksString
	---@type focksFunction
	set = objects.func(function(arg)
		if not type(arg):match("tring", 2) then
			error("You can only use strings as variable names!")
		end
		---@param arg2 focksObject
		return objects.func(function(arg2)
			local old_value
			pcall(function()
				old_value = MEMORY[arg.value]
			end)
			MEMORY[arg.value] = arg2
			return old_value
		end)
	end),
	concat = objects.func(function(arg)
		return function(arg2)
			log("Concatinating " .. arg .. " and " .. arg2)
			return objects.string(arg .. arg2)
		end
	end),
	---@param arg focksString
	---@return function
	contains = objects.func(function(arg)
		---@param arg2 focksObject
		---@return boolean
		return function(arg2)
			if type(arg) == "focksString" then
				if string.find(arg.value, tostring(arg2), 1, true) then
					return true
				end
			end
			return false
		end
	end),
	-- these are also literals in lua lmao
	---@type focksBoolean
	["true"] = objects.boolean(true),
	---@type focksBoolean
	["false"] = objects.boolean(false),
	---@type focksString
	_VERSION = objects.string(VERSION),
	_LUA_VERSION = objects.string(_G._VERSION),
}

setmetatable(ret, {
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
})

return ret
