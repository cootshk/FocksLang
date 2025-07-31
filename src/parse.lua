local lineNum = 0
---@type table, string, function
local helpers = require("helpers")
_G.MEMORY = require("builtins")
setmetatable(MEMORY, {
	__index = function(self, key)
		if type(key) == "focksString" then
			return function(index)
				return helpers.get(key, index)
			end
		elseif type(key) == "function" then
			log("key is", key)
			return function(args)
				log("args are", args)
				---@diagnostic disable-next-line: undefined-global
				return call_function(key, args)
			end
		elseif type(key) == "string" then
			error("Variable '".. key .. "' is not defined!")
		else
			error("Grabbing the memory of ".. type(key) .. " is not implemented!")
		end
	end,
})
---Calls `func` with `arg`
---@param func focksFunction
---@param arg focksObject
---@return focksObject
local function call_function(func, arg)
	if type(func) ~= "focksFunction" then
		error("Attempted to call "..type(arg) .. " as a function.")
	end
	return func(arg)
end

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
local escapes = {
	a="\a",
	b="\b",
	f="\f",
	n="\n",
	r="\r",
	t="\t",
	v="\v",
	-- the backslashes before these should be removed
	["\\"]="\\",
	["\""]="\"",
	["'"]="'",
}
---@param line string
return function(line)
	lineNum = lineNum + 1
	log("Line " .. lineNum .. " (" .. line .. ").")
	local blocks = {}
	do
		local block = ""
		local is_string = false
		local is_backslash = false
		for char in (line .. " "):gmatch(".") do
			if is_backslash then
				local esc = escapes[char]
				if esc then
					block = block .. esc
				else
					block = block .. "\\" .. char
				end
				is_backslash = false
			elseif char == " " and not is_string then
				table.insert(blocks, block)
				block = ""
			elseif char == "\\" and is_string then
				is_backslash = true
			elseif char == "\"" then
				is_string = not is_string
				block = block .. char
			else
				block = block .. char
			end
		end
	end
	if #blocks == 1 then
		table.insert(blocks, 0, "print")
	end
	log("Blocks: "..#blocks)
	local statements = {}
	for i, block in ipairs(blocks) do
		log("Parsing "..lineNum.."."..i..": "..block)
		table.insert(statements, parse_block(block))
	end
	repeat
		local func = table.remove(statements, 1)
		local arg = table.remove(statements, 1)
		table.insert(statements, 1, call_function(func, arg))
	until #statements <= 1
end
