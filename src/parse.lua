local lineNum = 0
---@type table, string, function
local helpers = require("helpers")
_G.MEMORY = require("builtins")
setmetatable(MEMORY, {
	__index = function(self, key)
		if helpers.type(key) == "focksString" then
			return function(index)
				return helpers.get(key, index)
			end
		elseif helpers.type(key) == "function" then
			print("key is", key)
			return function(args)
				print("args are", args)
				---@diagnostic disable-next-line: undefined-global
				return call_function(key, args)
			end
		else
			error("not implemented")
		end
	end,
})

---Gets the name of the first function
---@param line string
---@return string
local function get_function_name(line)
	return line:gmatch("[^ ]+")()
end
---@param line string
---@return string
local function get_function_args(line)
	return line:sub(#get_function_name(line) + 2)
end
---Calls the function, recursively calling input argument functions right to left
---@param func str
---@param argument string
---@return any?
local function call_function(func, argument)
	-- TODO: function variables
	---@type any
	local arg = argument
	if argument:sub(1, 1) == '"' then
		local end_quote = argument:find('"', 2, true)
		if not end_quote then
			error("Unmatched quote!")
		end
		---@type focksString
		print(#argument .. " vs " .. end_quote)
		if #argument > end_quote + 1 then
			-- we doing a substring boisss
			local index = tonumber(argument:sub(end_quote + 2))
			arg = helpers.string(helpers.get(argument, index + 1))
			print("Substringed arg: " .. arg .. " at pos " .. index)
		else
			arg = helpers.string(argument:sub(2, end_quote - 1))
		end
	end
	MEMORY[func](arg)
end
---@param line string
return function(line)
	lineNum = lineNum + 1
	print("Line " .. lineNum .. " (" .. line .. ").")
	call_function(get_function_name(line), get_function_args(line))
end
