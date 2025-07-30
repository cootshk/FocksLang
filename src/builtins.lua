-- All builtins here are exposed to end users
local helpers = require("helpers")
local old = require("globals")

---@type table, string, focksObject
local ret = {
	---@type focksFunction
	print = helpers.func(function(arg)
		print(arg.value)
		return arg -- daisy chained
	end),
	---@param arg focksString
	---@type focksFunction
	set = helpers.func(function(arg)
		if not type(arg):match("tring", 2) then
			error("You can only use strings as variable names!")
		end
		return function(arg2)
			MEMORY[arg] = arg2
			return arg2 -- also daisy chained
		end
	end),
	-- these are also literals in lua lmao
	---@type focksBoolean
	['true'] = helpers.boolean(true),
	---@type focksBoolean
	['false'] = helpers.boolean(false),
	---@type focksString
	_VERSION = helpers.string(VERSION),
}

setmetatable(ret, {
	---@param self table
	---@param key str
	__index = function (self, key)
		--[[if type(key) == "string" then
			error("Variable "..key.." is not defined!")
		else]]if type("key") == "focksString" then
			return self[key.value]
		end
	end
})

return ret