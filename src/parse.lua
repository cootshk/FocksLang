local lineNum = 0
---@type table, string, function
local helpers = require("helpers")
_G.MEMORY = require("builtins")
local old_globals = require("globals")

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
---@param func focksFunction|function
---@param arg focksObject
---@return focksObject
local function call_function(func, arg)
	if type(func) == "function" then
		func = helpers.func(func)
	end
	if type(func) ~= "focksFunction" then
		error("Attempted to call "..type(func) .. " (" .. tostring(func) .. ") as a function.")
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
-- functions
local run, evaluate, parse
---Parses a line (string) and returns a list of focksObjects to be run
---@param line string
---@param is_paren boolean?
---@return focksObject[]
function parse(line, is_paren)
	if not is_paren then
		lineNum = lineNum + 1
		log("Line " .. lineNum .. " (" .. line .. ").")
	else
		log("Invoked parse inside parens: ("..line..")")
	end
	local blocks = {}
	do
		local block = ""
		local is_string = false
		local is_backslash = false
		local total_paren_count = 0
		local total_end_paren_count = 0
		local skip_paren_count = 0
		---@type integer?
		local paren_expression_start = nil
		local i = 0
		for char in (line .. " "):gmatch(".") do
			i = i + 1
			if is_backslash then
				local esc = escapes[char]
				if esc then
					block = block .. esc
				else
					block = block .. "\\" .. char
				end
				is_backslash = false
			elseif char == "\"" then
				is_string = not is_string
				block = block .. char
			elseif char == "\\" and is_string then
				is_backslash = true
			elseif is_string then
				block = block .. char
			elseif char == ")" then
				total_end_paren_count = total_end_paren_count + 1
				if skip_paren_count > 0 then
					skip_paren_count = skip_paren_count - 1
					block = ""
					if skip_paren_count == 0 then
						log("Total paren count: "..total_paren_count-total_end_paren_count)
						assert(paren_expression_start, "Syntax error: end parentheses without a corresponding start parentheses on line ".. lineNum)
						local result = run(line:sub(paren_expression_start+1, i-1), true)
						table.insert(blocks, result)
						log("Got result (type ".. type(result) .. "): ", result)
						paren_expression_start = nil
						log("End of paren expression")
					end
				elseif not is_paren and total_end_paren_count > total_paren_count then
					error("Syntax error: missing end parentheses on line "..lineNum)
				else
					table.insert(blocks, block)
					break
				end
			elseif skip_paren_count > 0 then -- we skip all of the other characters
				if char == "(" then
					-- increse the counter here so we don't error
					total_paren_count = total_paren_count + 1
					skip_paren_count = skip_paren_count + 1
				end
			elseif char == "(" then
				total_paren_count = total_paren_count + 1
				if total_paren_count-total_end_paren_count == 1 then
					table.insert(blocks, block)
					block = ""
					paren_expression_start = i
				end
				skip_paren_count = skip_paren_count + 1
			elseif char == " " then
				table.insert(blocks, block)
				block = ""
			else
				block = block .. char
			end
		end
	end
	log("Blocks: "..#blocks)
	---@type focksObject[]
	local statements = {}
	for i, block in ipairs(blocks) do
		if block == "" or not block then
			log("TODO: fix (received empty string as a block)")
		elseif type(block):find("focks") then
			log("Copying "..lineNum.."."..i..": "..block.value)
			table.insert(statements, block)
		else
			log("Parsing "..lineNum.."."..i..": \'"..block.."\'")
			table.insert(statements, parse_block(block))
		end
	end
	return statements
end
---Evaluates a list of focksObjects and returns the result
---@param statements focksObject[]
---@return focksObject
function evaluate(statements)
	log("Evaluating ".. #statements .. " statements")
	local i = 0
	if #statements == 1 then
		return statements[1]
	elseif #statements == 0 then
		error("No statements?\nThis is an internal bug in Focks and should never be encountered.")
	end
	while #statements > 1 do
		i = i + 1
		log("Running statement ".. i)
		-- stupid way to strip nils
		local func
		repeat 
			func = table.remove(statements, 1)
		until func
		local arg
		repeat
			if #statements == 0 then
				return func
			end
			arg = table.remove(statements, 1)
		until arg
		table.insert(statements, 1, call_function(func, arg))
	end
	return statements[1]
end
---Runs a line of code
---@param line string
---@param is_paren boolean?
function run(line, is_paren)
	local statements = parse(line, is_paren)
	return evaluate(statements)
end
return run
