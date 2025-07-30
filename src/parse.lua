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
			log("key is", key)
			return function(args)
				log("args are", args)
				---@diagnostic disable-next-line: undefined-global
				return call_function(key, args)
			end
		else
			error("not implemented")
		end
	end,
})

-- A line contains multiple blocks, which can be variables, function definitions, or literals (true, "asdf", 1, etc)
---Gets the fock object corresponding to the parsed word
---@param argument string
---@return focksObject
local function parse_block(argument)
	---@type any
	local arg = argument
	if argument:sub(1, 1) == '"' then
		local end_quote = argument:find('"', 2, true)
		if not end_quote then
			error("Unmatched quote!")
		end
		---@type focksString
		-- log(#argsument .. " vs " .. end_quote)
		if #argument > end_quote + 1 then
			-- we doing a substring boisss
			local index = tonumber(argument:sub(end_quote + 2))
			arg = helpers.string(helpers.get(argument, index + 1))
			-- log("Substringed arg: " .. arg .. " at pos " .. index)
		else
			arg = helpers.string(argument:sub(2, end_quote - 1))
		end
	elseif tonumber(argument) then
		arg = helpers.int(tonumber(argument))
	elseif table.contains({'true', 'false'}, argument) then
		arg = helpers.boolean(argument == 'true')
	else
		---@type focksObject
		arg = MEMORY[argument]
		if not arg then
			error(string.format("Error: {} is not defined.", 2))
		end
	end
	return arg
end
---@param line string
return function(line)
	lineNum = lineNum + 1
	log("Line " .. lineNum .. " (" .. line .. ").")
	for char in line:gmatch(".") do
		print(char)
	end
end
